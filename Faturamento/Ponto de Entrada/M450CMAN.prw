#Include "Protheus.ch"
#Include "TOPCONN.ch"
#Include "TOTVS.ch"

//--------------------------------------------------------------------
/*/ Rotina MATA450A
  Ponto de entrada M450CMAN
 
   Este ponto pertence a rotina de libera��o de cr�dito, MATA450(). 
   Est� localizado na libera��o manual do cr�dito por cliente, 
   MA450CLMAN(). Permite que a libera��o / rejei��o seja validada
   antes de efetivada.

   Implementado para:
      - Enviar Pedido de Venda para o FUSION.

  @author Anderson Almeida - TOTVS
  @since   28/08/2024 
/*/
//-------------------------------------------------------------------- 
User Function M450CMAN()
  Local aArea   := GetArea()
  Local nOpcao  := Paramixb[1]            // 1 (Libera) ou 3 (Rejeita)
  Local oFusion := PCLSFUSION():New()
  Local aRet    := {}
  Local aRetEnv := {}
  Local lRet    := .T.
  Local nX      := 0
  Local nPrxSeq := 0

  If nOpcao == 1
     dbSelectArea("SC5")
     SC5->(dbSetOrder(1))

     PED->(dbGoTop())
     
     While ! PED->(Eof())
       If SC5->(dbSeek(FWxFilial("SC5") + PED->C5_NUM))  
          If SC5->C5_TPCARGA == "1"
             If ! Empty(SC5->C5_XSEQFUS)
                nPrxSeq := Val(SC5->C5_XSEQFUS) + 1
             EndIf

            // --- Parametro: 1 - Pedido Venda
            //                2 - Testar bloqueio do Pedido
            //                3 - Sequencial do Pedido
            //                4 - Registro deletado
            // ---------------------------------------------
             aRet := oFusion:LerPedidoVenda(SC5->C5_NUM,nPrxSeq,.F.,.F.)

             If aRet[01]
                If Len(aRet[04]) > 0                                // Itens do Pedido de Venda Liberada                      
                   oFusion:aRegistro := aRet[04]                    // Registro do Pedido de Venda

                   oFusion:saveEntregaServico("1","S",.F.)          // 1 - Normal, B - Bloqueado ou C - Cancelado e Forma Carga
           
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
                      ApMsgAlert(aRetEnv[02],"ATEN��O")  
                   EndIf
                EndIf
              else
                ApMsgAlert(aRet[02],"ATEN��O")  
             EndIf
          EndIf
        else
          ApMsgAlert("Pedido n�o encontrado.","ATEN��O")

          lRet := .F.

          Exit
       EndIf

       PED->(dbSkip())
     EndDo       
  EndIf

  RestArea(aArea)
Return lRet
