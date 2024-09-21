#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"
#INCLUDE "Tbiconn.ch"

/*/{Protheus.doc} prxNUM
Fonte utilizado para gerar numeração automática ao incluir títulos manualmente baseado no prefixo.
@type function
@author Elvis Siqueira
@since 09/09/2024
/*/

User Function prxNUM(pTabela,pCampo,pPrefixo) As Character
	Local aArea  	As Array
	Local cQry		As Character
	Local cSeq		As Character
	Local cTRB		As Character


	aArea  	:= FWGetArea()
	cTRB		:= GetNextAlias()
	cSeq 		:= StrZero(1, FWTamSX3(pCampo)[1])

	cQry := " SELECT MAX("+pCampo+") MAXCAMPO"
	cQry += " FROM " + RetSqlName(pTabela)
	cQry += " WHERE D_E_L_E_T_ <> '*'"
	if !Empty(pPrefixo)
		if AllTrim(FunName()) $ ('FINA040/FINA740') 
			cQry += " AND E1_PREFIXO = '" + AllTrim(pPrefixo) + "' "
		elseif AllTrim(FunName()) $ ('FINA050/FINA750')
			cQry += " AND E2_PREFIXO = '" + AllTrim(pPrefixo) + "' "
		endif
	endif

	cQry := ChangeQuery(cQry)

	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQry), cTRB)

	If (cTRB)->(!Eof()) .And. !Empty((cTRB)->(MAXCAMPO))
		cSeq := Soma1((cTRB)->(MAXCAMPO))
	EndIf

	(cTRB)->(DbCloseArea())

	FWRestArea(aArea)
	
return cSeq
