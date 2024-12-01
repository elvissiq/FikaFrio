#INCLUDE "Totvs.ch"
#INCLUDE 'Protheus.ch'
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} xAlteraDado
  Carga de dados para alteração
  @type Function de Usuario
  @author TOTVS Recife (Elvis Siqueira)
  @since 05/11/2024
  @version 1.0
  /*/

User Function xAlteraPrv()
  
  Processa({|| fProcess()}, "Filtrando...")

Return 

Static Function fProcess()
  Local aArea := FwGetArea()
  Local cConteudo := ""
  Local cQry  := ""
  Local _cAlias := GetNextAlias()
  Local nTotal := 0
  Local nAtual := 0
  Local nY

  cQry := "  SELECT SB1.B1_COD, SB1.B1_DESC FROM " + RetSqlName("SB1") + " SB1 "
  cQry += "  WHERE SB1.D_E_L_E_T_ <> '*' "
  cQry += "    AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
  cQry := ChangeQuery(cQry)
	DbUseArea(.T., "TOPCONN", TcGenQry(,, cQry), _cAlias)
  Count To nTotal
  ProcRegua(nTotal)

  (_cAlias)->(DbGoTop())

  DBSelectArea("SB1")

  While (_cAlias)->(!Eof())
    
    nAtual++

    IncProc("Processando registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")

    IF SB1->(MSSeek(xFilial("SB1") + (_cAlias)->B1_COD ))
      
      cConteudo := FwNoAccent((_cAlias)->B1_DESC)

      For nY := 1 To 12
        cConteudo := StrTran(cConteudo, "'", " ")
        cConteudo := StrTran(cConteudo, '#', " ")
        cConteudo := StrTran(cConteudo, '%', " ")
        cConteudo := StrTran(cConteudo, '*', " ")
        cConteudo := StrTran(cConteudo, '&', "E")
        cConteudo := StrTran(cConteudo, '>', " ")
        cConteudo := StrTran(cConteudo, '<', " ")
        cConteudo := StrTran(cConteudo, '!', " ")
        cConteudo := StrTran(cConteudo, '@', " ")
        cConteudo := StrTran(cConteudo, '$', " ")
        cConteudo := StrTran(cConteudo, '(', " ")
        cConteudo := StrTran(cConteudo, ')', " ")
        cConteudo := StrTran(cConteudo, '_', " ")
        cConteudo := StrTran(cConteudo, '=', " ")
        cConteudo := StrTran(cConteudo, '+', " ")
        cConteudo := StrTran(cConteudo, '{', " ")
        cConteudo := StrTran(cConteudo, '}', " ")
        cConteudo := StrTran(cConteudo, '[', " ")
        cConteudo := StrTran(cConteudo, ']', " ")
        cConteudo := StrTran(cConteudo, '/', " ")
        cConteudo := StrTran(cConteudo, '?', " ")
        cConteudo := StrTran(cConteudo, '.', " ")
        cConteudo := StrTran(cConteudo, '\', " ")
        cConteudo := StrTran(cConteudo, '|', " ")
        cConteudo := StrTran(cConteudo, ':', " ")
        cConteudo := StrTran(cConteudo, ';', " ")
        cConteudo := StrTran(cConteudo, '"', " ")
        cConteudo := StrTran(cConteudo, '°', " ")
        cConteudo := StrTran(cConteudo, 'ª', " ")
      Next 

      RecLock("SB1",.F.)
        B1_DESC := AllTrim(cConteudo)
      SB1->(MSUnlock())

    EndIF

  (_cAlias)->(DBSkip())
  End 

  (_cAlias)->(DbCloseArea())

  FwRestArea(aArea)
Return
