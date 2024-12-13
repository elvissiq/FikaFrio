#Include "PROTHEUS.ch"
#Include "parmtype.ch"

//--------------------------------------------------------
/*/ Rotina OMSA200

  Ponto de entrada OS200ASS

   Ap�s grava��o da manutencao da carga.
   
   Implementado para:
     - Enviar altera��o da Carga para o FUSION.

  @author Anderson Almeida - TOTVS
  @since   09/12/2024 
/*/
//--------------------------------------------------------
User Function OS200ASS()
  Local oFusion := PCLSFUSION():New()
  Local aRet    := {}

  oFusion:atualizaCarga()              // Montar requisi��o de envio

  aRet := oFusion:Enviar("atualizaCarga")
 
  If aRet[01]
     ApMsgInfo("Altera��o de Ve�culo/Motorista enviado para FUSION com sucesso.")
   else
     ApMsgAlert("Retorno com erro: " + Chr(13) + Chr(10) + aRet[02],"ATEN��O - Integra��o FUSION")  
  EndIf
Return
