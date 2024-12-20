#Include "Protheus.ch"
#Include "TOPCONN.ch"
#Include "TOTVS.ch"

//--------------------------------------------------------------------
/*/ Rotina MATA450
  Ponto de entrada MTA450T

   Executado ap�s a grava��o de todas as libera��es
   do pedido de vendas (Libera��o Manual) tabela SC9.

   Implementado para:
      - Enviar Pedido de Venda para o FUSION.

  @author Anderson Almeida - TOTVS
  @since   28/08/2024
/*/
//-------------------------------------------------------------------- 
User Function MT450FIM()
  Local cPedido := ParamIxb[1]
  Local oFusion := PCLSFUSION():New()
  Local aRet    := {}
  Local aRetEnv := {}
  Local lRet    := .T.
  Local nPrxSeq := 0
  Local nX      := 0
  Local cRetPrx := ""

  dbSelectArea("SC5")
  SC5->(dbSetOrder(1))
  SC5->(dbSeek(FWxFilial("SC5") + cPedido))

  If SC5->C5_TPCARGA == "1"
    // -- Parametro: 1 - Pedido Venda
    //                2 - Testar bloqueio do Pedido
    //                3 - Sequencial do Pedido
    //                4 - Registro deletado
    // --------------------------------------------
     cRetPrx := oFusion:pegarPrxSeq(SC5->C5_NUM, SC9->(Recno()))
     nPrxSeq := IIf(Empty(cRetPrx),0,Val(cRetPrx) + 1)
     aRet    := oFusion:LerPedidoVenda(SC5->C5_NUM,nPrxSeq,.F.,.F.)

     If aRet[01]
        If Len(aRet[04]) > 0                                
           oFusion:aRegistro := aRet[04]                       // Registro do Pedido de Venda

           oFusion:saveEntregaServico("1","S",.F.)             // 1 - Normal, B - Bloqueado ou C - Cancelado e Forma Carga
           
           aRetEnv := oFusion:Enviar("saveEntregaServico")
           
           If aRetEnv[01]
              dbSelectArea("SC9")
              SC9->(dbSetOrder(1))

              For nX := 1 To Len(oFusion:aRegistro)
                  SC9->(dbGoto(oFusion:aRegistro[nX][24]))

                  RecLock("SC9",.F.)
                    Replace SC9->C9_XSEQFUS with PadL(AllTrim(Str(nPrxSeq)),TamSX3("C9_XSEQFUS")[1],"0")
                  SC9->(MsUnlock())
              Next

              ApMsgInfo("Pedido enviado para FUSION com sucesso.")
            else
              ApMsgAlert(aRetEnv[02],"ATEN��O")  
           EndIf
        EndIf
      else
        ApMsgAlert(aRet[02],"ATEN��O")
     EndIf   
  EndIf
Return lRet
