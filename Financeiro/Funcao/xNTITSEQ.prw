//Bibliotecas
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TopConn.ch"
#INCLUDE "Tbiconn.ch"

/*/{Protheus.doc} xNTITSEQ
Gera o número sequencial do título SE1/SE2 de Acordo com o Prefixo.
@type user function
@author TOTVS Recife - Taiuã Nascimento
@collab TOTVS Recife - Anderson Almeida
@since 16/12/2024
@version 1.0 TOTVS Linha Protheus 12.1.2310
@return return_var: cSeq, return_type: Char, return_description: Retorna o sequência da loja.
/*/

User Function xNTITSEQ(pTabela,pPrefixo)

  Local cQry as Character
  Local cSeq   as Character
	Local cTRB   as Character
	Local cPref  as Character
  Local cGetArea as Character

    cGetArea := GetArea()

    cPref := Substr(pTabela,2,2)

  cTRB	:= GetNextAlias()
	cSeq 	:= StrZero(1, FWTamSX3(cPref + "_NUM")[1])
  cQry := " SELECT MAX(" + cPref + "_NUM) as MAXCAMPO"
	cQry += " FROM " + RetSqlName("S" + cPref)
	cQry += " WHERE D_E_L_E_T_ <> '*'"
	cQry += "   AND " + cPref + "_FILIAL = '" + FWxFilial(pTabela) + "'"
	cQry += "   AND " + cPref + "_PREFIXO = '" + pPrefixo + "'"
	cQry := ChangeQuery(cQry)

	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQry), cTRB)

	If ! (cTRB)->(Eof()) .And. ! Empty((cTRB)->MAXCAMPO)
		cSeq := Soma1((cTRB)->MAXCAMPO)
	else
		cSeq := "000000001"
	EndIf

	(cTRB)->(DbCloseArea())

    RestArea(cGetArea)

Return cSeq
