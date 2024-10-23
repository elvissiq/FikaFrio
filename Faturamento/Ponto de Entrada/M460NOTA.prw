#Include "Protheus.ch"
#Include "TBICONN.CH"
#Include "TopConn.ch"

/*-----------------------------------------------------------------------------------------------------*
| P.E.:  M460NOTA                                                                                      |
| Desc:  Ponto de entrada 'M460NOTA', executado ao final do processamento de todas as notas fiscais    |
|        selecionadas na markbrowse e recebe como parametro o alias da tabela.                         |
| Links: https://tdn.totvs.com.br/display/public/PROT/M460NOTA+-+Processanto+de+NFs                    |
*-----------------------------------------------------------------------------------------------------*/

User function M460NOTA()
    Local aAreaSF2   := SF2->(FWGetArea())
	Local aAreaDAK   := DAK->(FWGetArea())
	Local aAreaSE1   := SE1->(FWGetArea())
    Local aAreaSA1   := SA1->(FWGetArea())
    Local aAreaSA6   := SA6->(FWGetArea())
    Local lGeraBol	 := SuperGetMV("MV_XBOLETO",.F.,.F.)
    Local cTabPar    := ""
    Local cQuery     := ""
    Local _cAlias    := GetNextAlias()
    Local lContinua  := .F.
    Local cBank      := ""
    Local cAgenc     := ""
    Local cContCC    := ""
    Local cSubCC     := ""
    Local nPosBk     := 0
    Local nPosAg     := 0
    Local nPosCc     := 0
    Local nY

    Private aTitM460 := {}

    IF ValType(PARAMIXB) == "A"
        cTabPar := PARAMIXB[1]
    Else
        Return
    EndIF
	
    Do Case 
        Case cTabPar == "DAK"
            cQuery := " SELECT DISTINCT SF2.F2_COND, SF2.F2_CLIENTE, SF2.F2_LOJA, SE1.E1_FILIAL, SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO "
            cQuery += " FROM " + RetSqlName("SF2") + " SF2 "
            cQuery += " INNER JOIN " + RetSqlName("SE1") + " SE1 ON SE1.E1_PREFIXO = SF2.F2_SERIE AND SE1.E1_NUM = SF2.F2_DOC "
            cQuery += " INNER JOIN " + RetSqlName("DAK") + " DAK ON DAK.DAK_COD = SF2.F2_CARGA "
            cQuery += " WHERE SF2.D_E_L_E_T_ <> '*'"
            cQuery += "     AND DAK.D_E_L_E_T_ <> '*'"
            cQuery += "     AND SE1.D_E_L_E_T_ <> '*'"
            cQuery += "     AND SF2.F2_FILIAL  = '" + xFilial("SF2") + "'"
            cQuery += "     AND DAK.DAK_FILIAL = '" + xFilial("DAK") + "'"
            cQuery += "     AND SE1.E1_FILIAL  = '" + xFilial("SE1") + "'"
            cQuery += "     AND DAK.DAK_OK     = '" + oMark:cMark + "'"
        Case cTabPar == "SC9"
            cQuery := " SELECT DISTINCT SF2.F2_COND, SF2.F2_CLIENTE, SF2.F2_LOJA, SE1.E1_FILIAL, SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO "
            cQuery += " FROM " + RetSqlName("SC9") + " SC9 "
            cQuery += " INNER JOIN " + RetSqlName("SF2") + " SF2 ON SF2.F2_DOC = SC9.C9_NFISCAL AND SF2.F2_SERIE = SC9.C9_SERIENF "
            cQuery += " INNER JOIN " + RetSqlName("SE1") + " SE1 ON SE1.E1_PREFIXO = SF2.F2_SERIE AND SE1.E1_NUM = SF2.F2_DOC " 
            cQuery += " WHERE SC9.D_E_L_E_T_ <> '*'"
            cQuery += "     AND SF2.D_E_L_E_T_ <> '*'"
            cQuery += "     AND SE1.D_E_L_E_T_ <> '*'"
            cQuery += "     AND SC9.C9_FILIAL  = '" + xFilial("SC9") + "'"
            cQuery += "     AND SF2.F2_FILIAL  = '" + xFilial("SF2") + "'"
            cQuery += "     AND SE1.E1_FILIAL  = '" + xFilial("SE1") + "'"
            cQuery += "     AND SC9.C9_OK   = '" + oMark:cMark + "'"
    EndCase 
    cQuery := ChangeQuery(cQuery)
    If Select(_cAlias) > 0
        (_cAlias)->(dbCloseArea())
    EndIf
    dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),_cAlias,.F.,.T.)

    DBSelectArea("SA1")
    DBSelectArea("SA6")

    While (_cAlias)->(!Eof())
        
        IF SA1->(MSSeek(xFilial("SA1") + (_cAlias)->F2_CLIENTE + (_cAlias)->F2_LOJA ))
            IF !Empty(SA1->A1_XBANCO) .And. !Empty(SA1->A1_XAGENCI) .And. !Empty(SA1->A1_XNUMCON) .And. !Empty(SA1->A1_XSUBCTA)
                cBank   := PadR(SA1->A1_XBANCO ,FWTamSX3("A6_COD")[1])
                cAgenc  := PadR(SA1->A1_XAGENCI,FWTamSX3("A6_AGENCIA")[1])
                cContCC := PadR(SA1->A1_XNUMCON,FWTamSX3("A6_NUMCON")[1])
                cSubCC  := PadR(SA1->A1_XSUBCTA,FWTamSX3("EA_SUBCTA")[1])
            Else
               (_cAlias)->(DBSkip()) 
            EndIF 
        EndIF

        IF SA6->(MSSeek(xFilial("SA6") + cBank + cAgenc + cContCC ))
            If AllTrim(SA6->A6_CFGAPI) <> '1'
                (_cAlias)->(DBSkip())
            EndIF 
        EndIF 
        
        nPosBk := AScan(aTitM460, {|x| AllTrim(x[1]) == cBank  })
        nPosAg := AScan(aTitM460, {|x| AllTrim(x[1]) == cAgenc })
        nPosCc := AScan(aTitM460, {|x| AllTrim(x[1]) == cContCC})

        If !Empty(nPosBk) .AND. !Empty(nPosAg) .AND. !Empty(nPosCc)
            aAdd(aTitM460, { cBank, cAgenc, cContCC, cSubCC })
        Else
            aAdd(aTitM460[nPosCc], { cBank, cAgenc, cContCC, cSubCC })
        EndIF 

        aAdd(aTitM460[nPosBk][02],{ {"E1_FILIAL" , (_cAlias)->E1_FILIAL},;
                                    {"E1_PREFIXO", (_cAlias)->E1_PREFIXO},;
                                    {"E1_NUM"    , (_cAlias)->E1_NUM},;
                                    {"E1_PARCELA", (_cAlias)->E1_PARCELA},;
                                    {"E1_TIPO"   , (_cAlias)->E1_TIPO} })

        (_cAlias)->(DBSkip())
    End
    
    If Select(_cAlias) > 0
        (_cAlias)->(dbCloseArea())
    EndIf

    //-----------------------------------------------------------------------------------------------------------
	//Monta borderô automaticamente
	If lGeraBol
        For nY := 1 To aTitM460
            IF Len(aTitM460[nY]) == 4
                fnGerBor(aTitM460[nY]) //Gera o borderô
            EndIF
        Next
    EndIF 
	//-----------------------------------------------------------------------------------------------------------

    FWRestArea(aAreaSA6)
    FWRestArea(aAreaSA1)
    FWRestArea(aAreaSF2)
	FWRestArea(aAreaDAK)
	FWRestArea(aAreaSE1)

Return

// -----------------------------------------
/*/ Função fnGerBor

   Gerar Bordero.

  @author Totvs Nordeste
  Return
/*/
// -----------------------------------------
Static Function fnGerBor()
  Local cTmp    := GetNextAlias()
  Local cFiltro := ""
  Local cNumBor := ""
  Local cEspec  := ""  
  Local aRegBor := {}

  Private lMsErroAuto    := .F.
  Private lMsHelpAuto    := .T.
  Private lAutoErrNoFile := .T.

 // -- Informações bancárias para o borderô
 // ---------------------------------------

  DBSelectArea("F77")
  IF F77->(MsSeek(FWxFilial("F77")+cBanco))
    While ! F77->(Eof()) .AND. F77->F77_BANCO == cBanco
      If F77->F77_SIGLA == PadR('DM',FWTamSX3("F77_SIGLA")[1]) 
        cEspec := F77->F77_ESPECI
        Exit
      EndIF 
      F77->(DBSkip())
    End 
  EndIf 

  aAdd(aRegBor, {"AUTBANCO"   , aTitM460[01][01]})
  aAdd(aRegBor, {"AUTAGENCIA" , aTitM460[01][02]})
  aAdd(aRegBor, {"AUTCONTA"   , aTitM460[01][03]})
  aAdd(aRegBor, {"AUTSITUACA" , PadR("1",FWTamSX3("E1_SITUACA")[1])})
  aAdd(aRegBor, {"AUTNUMBOR"  , PadR(cNumBor,FWTamSX3("E1_NUMBOR")[1])}) // Caso não seja passado o número será obtido o próximo pelo padrão do sistema
  aAdd(aRegBor, {"AUTSUBCONTA", aTitM460[01][04]})
  aAdd(aRegBor, {"AUTESPECIE" , cEspec})
  aAdd(aRegBor, {"AUTBOLAPI"  , .T.})

  MsExecAuto({|a,b| FINA060(a,b)},3,{aRegBor, aTitM460[02]})

  If lMsErroAuto
    MostraErro()
  EndIf

Return
