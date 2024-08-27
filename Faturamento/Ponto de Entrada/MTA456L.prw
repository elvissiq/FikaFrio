#Include "Protheus.ch"
#Include "TOPCONN.ch"
#Include "TOTVS.ch"

//--------------------------------------------------------------------
/*/ Rotina MATA456
  Ponto de entrada MTA456L
   
   Executado após a gravação de todas as liberações do pedido de
   vendas (Liberação Manual) tabela SC9.

   Implementado:
     - Enviar Pedido de Venda para o FUSION.

  @Autor Anderson Almeida - TOTVS
  @since  27/08/2024 - Desenvolvimento da Rotina.
/*/
//-------------------------------------------------------------------- 
User Function MTA456L()
  Local nOpc    := ParamIxb[1]       // 1 = OK, 3 = Rejeita ou 4 = Libera todos
  Local oFusion := PCLSFUSION():New()
  Local aRet    := {}
  Local aRetEnv := {}
  Local nX      := 0
  Local nPrxSeq := 0

  If nOpc == 1 .or. nOpc == 4
     If SC5->C5_TPCARGA == "1"
        If ! Empty(SC5->C5_XSEQFUS)
           nPrxSeq := Val(SC5->C5_XSEQFUS) + 1
        EndIf

       // -- Parametro: 1 - Pedido Venda
       //                2 - Testar bloqueio do Pedido
       //                3 - Sequencial do Pedido
       //                4 - Registro deletado
       // --------------------------------------------
        aRet := oFusion:LerPedidoVenda(SC5->C5_NUM,nPrxSeq,.F.,.F.)

        If aRet[01]
           If Len(aRet[04]) > 0                             // Itens do Pedido de Venda Liberada                          
              oFusion:aRegistro := aRet[04]                 // Registro do Pedido de Venda

              oFusion:saveEntregaServico("1","S",.F.)       // 1 - Normal, B - Bloqueado ou C - Cancelado e Forma Carga
           
              aRetEnv := oFusion:Enviar("saveEntregaServico")

              If aRetEnv[01]
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
               else
                 ApMsgAlert(aRet[02],"ATENÇÃO")  
              EndIf
            else
              ApMsgAlert(aRet[02],"ATENÇÃO")  
           EndIf
        EndIf   
     EndIf   
  EndIf
Return
