#Include "PROTHEUS.ch"
#Include "parmtype.ch"

//---------------------------------------------------------------
/*/ Rotina OMSA040
  Ponto de Entrada OS040GRV

    Executado ap�s a grava��o do cadastro de motoristas e pode
    ser utilizado para complemento de grava��o do mesmo ou de 
    uma tabela auxiliar.

    Implementado para:
      - Enviar Motorista para o FUSION.

  @Autor TOTVS NE (Anderson Almeida)
  @sample
  Retorno
  @hist�ria
  15/02/2021 - Desenvolvimento da Rotina.
/*/
//--------------------------------------------------------------- 
User Function OS040GRV()
  Local nOpc    := ParamIxb[1]                    // 3 - Inclus�o, 4 - Altera��o ou 5 - Exclus�o
  Local oFusion := PCLSFUSION():New()
  Local aRet    := .F.

  If nOpc < 3 .or. nOpc > 4
     Return
  EndIf

  oFusion:sendMotoristas(DA4->DA4_COD)              // Montar requisi��o de envio

  aRet := oFusion:Enviar("sendMotoristas")
 
  If aRet[01]
     ApMsgInfo(aRet[02])
   else
     ApMsgAlert(aRet[02],"ATEN��O")  
  EndIf
Return
