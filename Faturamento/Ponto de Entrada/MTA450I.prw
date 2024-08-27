#Include "Protheus.ch"
#Include "TOPCONN.ch"
#Include "TOTVS.ch"

//-------------------------------------------------------
/*/ Rotina MATA450A
  Ponto de entrada MTA450I

   Pertence a rotina de liberação de crédito, MATA450. 
   Executado apos atualizacao da liberacao de pedido.
    
   Implementado para:
     - Enviar Pedido de Venda para o FUSION.

  @author Anderson Almeida - TOTVS
  @since   28/08/2024 
/*/
//-------------------------------------------------------- 
User Function MTA450I()
  Local aArea   := GetArea()
  Local oFusion := PCLSFUSION():New()
  Local lUpSC9  := .F.
  Local aRet    := {}
  Local aRetEnv := {}
  Local nX      := 0
  Local nPrxSeq := 0
  Local cQuery  := ""

  If ValType(mv_par30) == "C"
     mv_par30 := 9999
  EndIf

  If mv_par30 == 9999   
     cQuery := "Select Count(*) as CONTE from " + RetSqlName("SC9")
     cQuery += "  where D_E_L_E_T_ <> '*'"
     cQuery += "    and C9_FILIAL  = '" + FWxFilial("SC9") + "'"
     cQuery += "    and C9_PEDIDO  = '" + SC9->C9_PEDIDO + "'"
     cQuery += "    and C9_BLCRED  = '01'"
     cQuery := ChangeQuery(cQuery)
     dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"QSC9",.F.,.T.)

     mv_par30 := QSC9->CONTE

     QSC9->(dbCloseArea())
   else
     mv_par30 := mv_par30 - 1
  EndIf        

  If SC5->C5_TPCARGA == "1" .and. mv_par30 == 0
    // -- Parametro: 1 - Pedido Venda
    //               2 - Testar bloqueio do Pedido
    //               3 - Sequencial do Pedido
    //               4 - Registro deletado
    // --------------------------------------------
     If SC9->C9_XSEQFUS <> SC5->C5_XSEQFUS
        nPrxSeq := Val(SC5->C5_XSEQFUS) + 1
        lUpSC9  := .T.
      else
        nPrxSeq := Val(SC5->C5_XSEQFUS)
        lUpSC9  := .F.  
     EndIf
        
     aRet := oFusion:LerPedidoVenda(SC5->C5_NUM,nPrxSeq,.F.,.F.)

     If aRet[01]
        If Len(aRet[04]) > 0                                // Itens do Pedido de Venda Liberada                      
           oFusion:aRegistro := aRet[04]                    // Registro do Pedido de Venda

           oFusion:saveEntregaServico("1","S",.F.)          // 1 - Normal, B - Bloqueado ou C - Cancelado e Forma Carga
          
           aRetEnv := oFusion:Enviar("saveEntregaServico")
 
           If ! aRetEnv[01]
              ApMsgAlert(aRetEnv[02],"ATENÇÃO")
            else
              If lUpSC9 
                 Reclock("SC5",.F.)
                   Replace SC5->C5_XSEQFUS with PadL(AllTrim(Str(nPrxSeq)),TamSX3("C5_XSEQFUS")[1],"0")
                 SC5->(MsUnlock())

                 dbSelectArea("SC9")
                 SC9->(dbSetOrder(1))

                 For nX := 1 To Len(oFusion:aRegistro)
                     SC9->(dbGoto(oFusion:aRegistro[nX][24]))

                     RecLock("SC9",.F.)
                       Replace SC9->C9_XSEQFUS with PadL(AllTrim(Str(nPrxSeq)),TamSX3("C9_XSEQFUS")[1],"0")
                     SC9->(MsUnlock())
                 Next
              EndIf   
           EndIf
        EndIf
      else
        ApMsgAlert(aRet[02],"ATENÇÃO")  
     EndIf

     mv_par30 := 9999
  EndIf

  RestArea(aArea)
Return
