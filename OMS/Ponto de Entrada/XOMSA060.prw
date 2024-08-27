#Include "PROTHEUS.ch"
#Include "parmtype.ch"

//-----------------------------------------------------
/*/ Rotina OMSA060
   Ponto de Entrada - OMSA060 (MVC)

    Cadastro de Veículos
    
    Implementado para:
     - Enviar Veículo para o FUSION.

  @Autor TOTVS NE (Anderson Almeida)
  @história
    27/08/2024 - Desenvolvimento da Rotina.
/*/
//------------------------------------------------------ 
User Function OMSA060()
  Local aParam   := PARAMIXB
  Local xRet     := .T.
  Local oObj     := ""
  Local cIdPonto := ""
  Local cIdModel := ""
  Local lIsGrid  := .F.
  Local oModel   := FwModelActive()

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
                fnEnviar()                         // Enviar veículos para o FUSION.
             EndIf

        Case cIdPonto == "FORMCOMMITTTSPRE"        // Chamada após a gravação da tabela do formulário.
        Case cIdPonto == "FORMCOMMITTTSPOS"        // Chamada após a gravação da tabela do formulário.
        Case cIdPonto == "MODELCANCEL"             // Chamada no cancelamento.
     EndCase
  EndIf    
Return xRet

//------------------------------------------
/*/ Função fnEnviar

   Envio do Veículo para o FUSION.

  Retorno
  @historia
   27/08/2024 - Desenvolvimento da Rotina.
/*/
//------------------------------------------
Static Function fnEnviar()
  Local oFusion := PCLSFUSION():New()
  Local aRet    := {}

  oFusion:sendVeiculos(DA3->DA3_COD)                 // Montar requisição de envio

  aRet := oFusion:Enviar("sendVeiculos")             // Enviar para FUSION
  
  If aRet[01]
     ApMsgInfo(aRet[02])
   else
     ApMsgAlert(aRet[02],"ATENÇÃO")  
  EndIf
Return
