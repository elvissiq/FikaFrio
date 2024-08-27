#Include "PROTHEUS.ch"
#Include "parmtype.ch"

//---------------------------------------------------------------
/*/ Rotina OMSA050
  Ponto de entrada OS050GRV

   Executado após a gravação do cadastro de Ajudante e pode ser
   utilizado para complemento de gravação do mesmo ou de uma 
   tabela auxiliar.
   
   Implementado para:
     - Enviar Ajudante para o FUSION.

  @Autor TOTVS NE (Anderson Almeida)
  @história
  14/04/2021 - Desenvolvimento da Rotina.
/*/
//--------------------------------------------------------------- 
User Function OS050GRV()
  Local nOpc    := ParamIxb[1]           // 3 - Inclusão, 4 - Alteração ou 5 - Exclusão
  Local oFusion := PCLSFUSION():New()
  Local aRet    := {}

  If nOpc < 3 .or. nOpc > 4
     Return
  EndIf

  oFusion:sendAjudantes(DAU->DAU_COD)              // Montar requisição de envio

  aRet := oFusion:Enviar("sendMotoristas")         // Enviar para FUSION (Ajudante)
  
  If aRet[01]
     ApMsgInfo(aRet[02])
   else
     ApMsgAlert(aRet[02],"ATENÇÃO")  
  EndIf
Return
