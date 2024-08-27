#Include "PROTHEUS.ch"
#Include "parmtype.ch"

//-----------------------------------------------------
/*/ Rotina OMSA060
   Ponto de Entrada - OMSA060 (MVC)

    Cadastro de Ve�culos
    
    Implementado para:
     - Enviar Ve�culo para o FUSION.

  @Autor TOTVS NE (Anderson Almeida)
  @hist�ria
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
        Case cIdPonto == "MODELPOS"                // Chamada na valida��o total do modelo.
        Case cIdPonto == "FORMPOS"                 // Chamada na valida��o total do formul�rio.
        Case cIdPonto == "FORMLINEPRE"             // Chamada na pr� valida��o da linha do formul�rio.
        Case cIdPonto == "FORMLINEPOS"             // Chamada na valida��o da linha do formul�rio.
        Case cIdPonto == "MODELCOMMITTTS"          // Chamada ap�s a grava��o total do modelo e dentro da transa��o.

        Case cIdPonto == "MODELCOMMITNTTS"         // Chamada ap�s a grava��o total do modelo e fora da transa��o.
             If oModel:GetOperation() == 3 .or. oModel:GetOperation() == 4
                fnEnviar()                         // Enviar ve�culos para o FUSION.
             EndIf

        Case cIdPonto == "FORMCOMMITTTSPRE"        // Chamada ap�s a grava��o da tabela do formul�rio.
        Case cIdPonto == "FORMCOMMITTTSPOS"        // Chamada ap�s a grava��o da tabela do formul�rio.
        Case cIdPonto == "MODELCANCEL"             // Chamada no cancelamento.
     EndCase
  EndIf    
Return xRet

//------------------------------------------
/*/ Fun��o fnEnviar

   Envio do Ve�culo para o FUSION.

  Retorno
  @historia
   27/08/2024 - Desenvolvimento da Rotina.
/*/
//------------------------------------------
Static Function fnEnviar()
  Local oFusion := PCLSFUSION():New()
  Local aRet    := {}

  oFusion:sendVeiculos(DA3->DA3_COD)                 // Montar requisi��o de envio

  aRet := oFusion:Enviar("sendVeiculos")             // Enviar para FUSION
  
  If aRet[01]
     ApMsgInfo(aRet[02])
   else
     ApMsgAlert(aRet[02],"ATEN��O")  
  EndIf
Return
