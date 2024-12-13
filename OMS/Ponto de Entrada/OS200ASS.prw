#Include "PROTHEUS.ch"
#Include "parmtype.ch"

//--------------------------------------------------------
/*/ Rotina OMSA200

  Ponto de entrada OS200ASS

   Após gravação da manutencao da carga.
   
   Implementado para:
     - Enviar alteração da Carga para o FUSION.

  @author Anderson Almeida - TOTVS
  @since   09/12/2024 
/*/
//--------------------------------------------------------
User Function OS200ASS()
  Local oFusion := PCLSFUSION():New()
  Local aRet    := {}

  oFusion:atualizaCarga()              // Montar requisição de envio

  aRet := oFusion:Enviar("atualizaCarga")
 
  If aRet[01]
     ApMsgInfo("Alteração de Veículo/Motorista enviado para FUSION com sucesso.")
   else
     ApMsgAlert("Retorno com erro: " + Chr(13) + Chr(10) + aRet[02],"ATENÇÃO - Integração FUSION")  
  EndIf
Return
