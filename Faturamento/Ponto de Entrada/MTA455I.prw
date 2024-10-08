#Include "Protheus.ch"
#Include "TOPCONN.ch"
#Include "TOTVS.ch"

//--------------------------------------------------------
/*/ Rotina MATA455
  Ponto de entrada MTA455I
    
   Na rotina Libera��o de Estoque, executado ap�s a
   grava��o de todas as libera��es do pedido de vendas
   (Libera��o Manual) tabela SC9.
    
   Implementado para:
     - Enviar Pedido de Venda para o FUSION.

  @author Anderson Almeida - TOTVS
  @since   28/08/2024 
/*/
//--------------------------------------------------------
User Function MTA455I()
  Local aArea   := GetArea()
  Local oFusion := PCLSFUSION():New()
  Local aRet    := {}
  Local aRetEnv := {}
  Local nPrxSeq := 0
  Local nX      := 0

  dbSelectArea("SC5")
  SC5->(dbSetOrder(1))
  SC5->(dbSeek(FWxFilial("SC5") + SC9->C9_PEDIDO))

  If SC5->C5_TPCARGA == "1"
    // -- Parametro: 1 - Pedido Venda
    //                2 - Testar bloqueio do Pedido
    //                3 - Sequencial do Pedido
    //                4 - Registro deletado
    // --------------------------------------------
     If ! Empty(SC5->C5_XSEQFUS)
        nPrxSeq := Val(SC5->C5_XSEQFUS) + 1
     EndIf

     aRet := oFusion:LerPedidoVenda(SC5->C5_NUM,nPrxSeq,.F.,.F.)

     If aRet[01]
       // -- Itens do Pedido de Venda Liberada
       // ------------------------------------
        If Len(aRet[04]) > 0                                
           oFusion:aRegistro := aRet[04]                       // Registro do Pedido de Venda

           oFusion:saveEntregaServico("1","S",.F.)             // 1 - Normal, B - Bloqueado ou C - Cancelado e Forma Carga
           
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
              ApMsgAlert(aRet[02],"ATEN��O")  
           EndIf
        EndIf
       // -----------------------------------
      else
        ApMsgAlert(aRet[02],"ATEN��O")  
     EndIf   
  EndIf

  RestArea(aArea)
Return
