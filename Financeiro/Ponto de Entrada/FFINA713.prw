#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

/*/{Protheus.doc} FFINA713
  Executa a rotina FINA713 manualmente quando o Schedule estiver com problemas
  @type  User Function
  @author TOTVS Nordeste (Elvis Siqueira)
  @since 21/03/2024
  @version 1.0
/*/

User Function FFINA713()

    F713Transf()

    FWAlertSuccess('Rotina FINA713 executada com sucesso','FINA713')

Return
