#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'Protheus.ch'
#INCLUDE 'FWMVCDef.ch'

/*/{Protheus.doc} xAlteraDado
  Carga de dados para alteração
  @type Function de Usuario
  @author TOTVS Recife (Elvis Siqueira)
  @since 22/08/2023
  @version 1.0
  /*/

User Function xAlteraPrv()
  Local aArea := FwGetArea()
  Local cQry  := ""
  Local _cAlias := GetNextAlias()

  cQry := "  SELECT CFC.CFC_UFORIG, CFC.CFC_UFDEST, CFC.CFC_CODPRD, SB1.B1_CONV  FROM " + RetSqlName("CFC") + " CFC "
  cQry += "  INNER JOIN  " + RetSqlName("SB1") + " SB1 "
  cQry += "  ON SB1.B1_COD = CFC.CFC_CODPRD "
  cQry += "  WHERE CFC.D_E_L_E_T_ <> '*' "
  cQry += "    AND SB1.D_E_L_E_T_ <> '*' "
  cQry += "    AND SB1.B1_FILIAL = " + xFilial("SB1") + " "
  cQry += "    AND SB1.B1_GRUPO IN ('071700','072700') "
  cQry := ChangeQuery(cQry)
	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQry), _cAlias)

  DBSelectArea("CFC")

  While (_cAlias)->(!Eof())
    IF CFC->(MSSeek(xFilial("CFC") + (_cAlias)->CFC_UFORIG + (_cAlias)->CFC_UFDEST + (_cAlias)->CFC_CODPRD ))
      RecLock("CFC",.F.)
        CFC_VL_ICM := ( CFC_VL_ICM * (_cAlias)->B1_CONV )
      CFC->(MSUnlock())
    EndIF 
  (__cAlias)->(DBSkip())
  End 

  (_cAlias)->(DbCloseArea())

  FwRestArea(aArea)
Return
