#Include "PROTHEUS.ch"
#Include "parmtype.ch"

//----------------------------------------------------
/*/ Rotina CRMA980
  Ponto de entrada CRMA980 (MVC)

   Cadastro de Cliente

   Implementado para:
     - Enviar Cliente para o FUSION.
     - Criar item Contábil.

  @Autor Anderson Almeida - TOTVS
  @história
    27/08/2024 - Desenvolvimento da Rotina.
/*/
//----------------------------------------------------- 
User Function CRMA980()
  Local aParam   := PARAMIXB
  Local xRet     := .T.
  Local oObj     := ""
  Local cIdPonto := ""
  Local cIdModel := ""
  Local lIsGrid  := .F.
  
  Private oModel := FwModelActive()

  If aParam <> NIL
     oObj     := aParam[1]
     cIdPonto := aParam[2]
     cIdModel := aParam[3]
     lIsGrid  := (Len(aParam) > 3)

     Do Case
        Case cIdPonto == "MODELPOS"                // Chamada na validação total do modelo.
        Case cIdPonto == "FORMPOS"                 // Chamada na validação total do formulário.
        Case cIdPonto == "FORMLINEPRE"             // Chamada na pré validação da linha do formulário.
        Case cIdPonto == "FORMLINEPOS"             // Chamada na validação da linha do formulário.
        Case cIdPonto == "MODELCOMMITTTS"          // Chamada após a gravação total do modelo e dentro da transação.

        Case cIdPonto == "MODELCOMMITNTTS"         // Chamada após a gravação total do modelo e fora da transação.
             If oModel:GetOperation() == 3 .or. oModel:GetOperation() == 4
                fnEnviar()                         // Enviar cliente para o FUSION.
                fnSetCTD()                         // Criar item Contábil.
             EndIf

        Case cIdPonto == "FORMCOMMITTTSPRE"        // Chamada após a gravação da tabela do formulário.
        Case cIdPonto == "FORMCOMMITTTSPOS"        // Chamada após a gravação da tabela do formulário.
        Case cIdPonto == "MODELCANCEL"             // Chamada no cancelamento.
        Case cIdPonto == "BUTTONBAR"               // Chamada na montagem da barra de opções.
     EndCase
  EndIf    
Return xRet

//------------------------------------------
/*/ Função fnEnviar

   Envio do cliente para o FUSION.

  Retorno
  @historia
   26/08/2024 - Desenvolvimento da Rotina.
/*/
//------------------------------------------
Static Function fnEnviar()
  Local oFusion := PCLSFUSION():New()
  Local aRet    := {}

  oFusion:sendClientes(SA1->A1_COD, SA1->A1_LOJA)    // Montar requisição de envio

  aRet := oFusion:Enviar("sendClientes")             // Enviar para FUSION
  
  If aRet[01]
     ApMsgInfo(aRet[02])
   else
     ApMsgAlert(aRet[02],"ATENÇÃO")  
  EndIf
Return

//------------------------------------------
/*/ Função fnSetCTD

   Criar item contábil.

  @historia
   26/08/2024 - Desenvolvimento da Rotina.
/*/
//------------------------------------------
Static Function fnSetCTD()
	Local oModelSA1 := oModel:GetModel("SA1MASTER")

	dbSelectArea("CTD")
	CTD->(dbSetOrder(1))

	If ! (CTD->(dbSeek(FWxFilial("CTD") + "C" + oModelSA1:GetValue("A1_COD") + oModelSA1:GetValue("A1_LOJA"))))
  	 RecLock("CTD",.T.)
		   Replace CTD->CTD_FILIAL with FWxFilial("CTD") 
		   Replace CTD->CTD_ITEM	 with "C" + oModelSA1:GetValue("A1_COD") + oModelSA1:GetValue("A1_LOJA")
		   Replace CTD->CTD_CLASSE with "2"
		   Replace CTD->CTD_NORMAL with "2"          
		   Replace CTD->CTD_DESC01 with oModelSA1:GetValue("A1_NOME")
		   Replace CTD->CTD_BLOQ	 with "2"    
		   Replace CTD->CTD_DTEXIS with CToD("01/01/1980")
		   Replace CTD->CTD_ITLP 	 with "C" + oModelSA1:GetValue("A1_COD") + oModelSA1:GetValue("A1_LOJA")
		 CTD->(MsUnLock())  

		 If SA1->(FieldPos("A1_XITEMCC")) > 0
				RecLock("SA1",.F.)
					Replace SA1->A1_XITEMCC with "C" + oModelSA1:GetValue("A1_COD") + oModelSA1:GetValue("A1_LOJA")
				SA1->(MsUnLock())
		 EndIf
	EndIf	
Return
