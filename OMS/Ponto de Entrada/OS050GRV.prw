#Include "PROTHEUS.ch"
#Include "parmtype.ch"

//---------------------------------------------------------------
/*/ Rotina OMSA050
  Ponto de entrada OS050GRV

   Executado ap�s a grava��o do cadastro de Ajudante e pode ser
   utilizado para complemento de grava��o do mesmo ou de uma 
   tabela auxiliar.
   
   Implementado para:
     - Enviar Ajudante para o FUSION.

  @Autor TOTVS NE (Anderson Almeida)
  @hist�ria
  14/04/2021 - Desenvolvimento da Rotina.
/*/
//--------------------------------------------------------------- 
User Function OS050GRV()
  Local nOpc    := ParamIxb[1]           // 3 - Inclus�o, 4 - Altera��o ou 5 - Exclus�o
  Local oFusion := PCLSFUSION():New()
  Local aRet    := {}

  If nOpc < 3 .or. nOpc > 4
     Return
  EndIf

  oFusion:sendAjudantes(DAU->DAU_COD)              // Montar requisi��o de envio

  aRet := oFusion:Enviar("sendMotoristas")         // Enviar para FUSION (Ajudante)
  
  If aRet[01]
     ApMsgInfo(aRet[02])
   else
     ApMsgAlert(aRet[02],"ATEN��O")  
  EndIf
Return
