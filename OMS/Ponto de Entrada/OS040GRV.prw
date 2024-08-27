#Include "PROTHEUS.ch"
#Include "parmtype.ch"

//---------------------------------------------------------------
/*/ Rotina OMSA040
  Ponto de Entrada OS040GRV

    Executado após a gravação do cadastro de motoristas e pode
    ser utilizado para complemento de gravação do mesmo ou de 
    uma tabela auxiliar.

    Implementado para:
      - Enviar Motorista para o FUSION.

  @Autor TOTVS NE (Anderson Almeida)
  @sample
  Retorno
  @história
  15/02/2021 - Desenvolvimento da Rotina.
/*/
//--------------------------------------------------------------- 
User Function OS040GRV()
  Local nOpc    := ParamIxb[1]                    // 3 - Inclusão, 4 - Alteração ou 5 - Exclusão
  Local oFusion := PCLSFUSION():New()
  Local aRet    := .F.

  If nOpc < 3 .or. nOpc > 4
     Return
  EndIf

  oFusion:sendMotoristas(DA4->DA4_COD)              // Montar requisição de envio

  aRet := oFusion:Enviar("sendMotoristas")
 
  If aRet[01]
     ApMsgInfo(aRet[02])
   else
     ApMsgAlert(aRet[02],"ATENÇÃO")  
  EndIf
Return
