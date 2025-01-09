#Include "Protheus.ch"
#Include "TOPCONN.ch"
#Include "TOTVS.ch"

//--------------------------------------------------------------------
/*/ Rotina MATA450A
  Ponto de entrada M450CMAN
 
   Este ponto pertence a rotina de liberação de crédito, MATA450(). 
   Está localizado na liberação manual do crédito por cliente, 
   MA450CLMAN(). Permite que a liberação / rejeição seja validada
   antes de efetivada.

   Implementado para:
      - Enviar Pedido de Venda para o FUSION.

  @author Anderson Almeida - TOTVS
  @since   28/08/2024
  @Historico 
  09/01/2025 - Comentado por Elvis Siqueira
/*/
//-------------------------------------------------------------------- 
User Function M450CMAN()
  Local lRet    := .T.
  /*
  Local aArea   := GetArea()
  Local nOpcao  := Paramixb[1]            // 1 (Libera) ou 3 (Rejeita)
  Local oFusion := PCLSFUSION():New()
  Local aRet    := {}
  Local aRetEnv := {}
  Local lRet    := .T.
  Local nX      := 0
  Local nPrxSeq := 0
  Local cRetPrx := ""

  If nOpcao == 1
     dbSelectArea("SC5")
     SC5->(dbSetOrder(1))

     PED->(dbGoTop())
   
     While ! PED->(Eof())
       If SC5->(dbSeek(FWxFilial("SC5") + PED->C5_NUM))  
          If SC5->C5_TPCARGA == "1"
             cRetPrx := oFusion:pegarPrxSeq(SC5->C5_NUM, SC9->(Recno()))
             nPrxSeq := IIf(Empty(cRetPrx),0,Val(cRetPrx) + 1)

            // --- Parametro: 1 - Pedido Venda
            //                2 - Sequencial do Pedido
            //                3 - Testar bloqueio do Pedido
            //                4 - Nota Fiscal de saída
            //                5 - Serie da NF de saída
            // ---------------------------------------------
             If ! oFusion:ValidaCad(SC5->C5_NUM)            // Validar Cadastro de Produto Complementos
                ApMsgAlert("Existe produto(s) sem cadastro complementar. " + CRLF +;
                           "Verifique o cadastro 'Complemento de Produto'.","ATENÇÃO")
                Return .F.
             EndIf 
             
             aRet := oFusion:LerPedidoVenda(SC5->C5_NUM,nPrxSeq,.F.,"","","","")

             If aRet[01]
                If Len(aRet[04]) > 0                                // Itens do Pedido de Venda Liberada                      
                   oFusion:aRegistro := aRet[04]                    // Registro do Pedido de Venda

                   oFusion:saveEntregaServico("1","S",.F.)          // 1 - Normal, B - Bloqueado ou C - Cancelado e Forma Carga
           
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

                      ApMsgInfo("Pedido enviado para FUSION com sucesso.","M450CMAN")
                    else
                      ApMsgAlert(aRetEnv[02],"ATENÇÃO")  
                   EndIf
                EndIf
              else
                ApMsgAlert(aRet[02],"ATENÇÃO")
             EndIf
          EndIf
        else
          ApMsgAlert("Pedido não encontrado.","ATENÇÃO")

          lRet := .F.

          Exit
       EndIf

       PED->(dbSkip())
     EndDo       
  EndIf

  RestArea(aArea)
  */
Return lRet
