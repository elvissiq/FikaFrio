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
    Local aArea     := FWGetArea()
    Local lGeraBol	:= SuperGetMV("MV_XBOLETO",.F.,.F.)
    Local cTabPar   := ""
    Local cQuery    := ""
    Local _cAlias   := GetNextAlias()
    Local cBank     := ""
    Local cAgenc    := ""
    Local cContCC   := ""
    Local cSubCC    := ""
    Local nPosBk    := 0
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
        
        nPosBk := AScan(aTitM460, {|x| AllTrim(x[1]) == cBank+";"+cAgenc+";"+cContCC+";"+cSubCC  })

        If Empty(nPosBk)
            aAdd(aTitM460,{ cBank+";"+cAgenc+";"+cContCC+";"+cSubCC })
            aTitAux := {}
            aAdd(aTitAux ,{ {"E1_FILIAL" , (_cAlias)->E1_FILIAL},;
                            {"E1_PREFIXO", (_cAlias)->E1_PREFIXO},;
                            {"E1_NUM"    , (_cAlias)->E1_NUM},;
                            {"E1_PARCELA", (_cAlias)->E1_PARCELA},;
                            {"E1_TIPO"   , (_cAlias)->E1_TIPO} })
            aAdd(aTitM460[Len(aTitM460)], aTitAux)
        Else
            aTitAux := {}
            aAdd(aTitAux ,{ {"E1_FILIAL" , (_cAlias)->E1_FILIAL},;
                            {"E1_PREFIXO", (_cAlias)->E1_PREFIXO},;
                            {"E1_NUM"    , (_cAlias)->E1_NUM},;
                            {"E1_PARCELA", (_cAlias)->E1_PARCELA},;
                            {"E1_TIPO"   , (_cAlias)->E1_TIPO} })
            aAdd(aTitM460[nPosBk], aTitAux)
        EndIF 

        (_cAlias)->(DBSkip())
    End
    
    If Select(_cAlias) > 0
        (_cAlias)->(dbCloseArea())
    EndIf

    //-----------------------------------------------------------------------------------------------------------
	//Monta borderô automaticamente
	If lGeraBol
        For nY := 1 To Len(aTitM460)
            fnGerBor(nY) //Gera o borderô
        Next
    EndIF 
	//-----------------------------------------------------------------------------------------------------------

    FWRestArea(aArea)

Return

// -----------------------------------------
/*/ Função fnGerBor

   Gerar Bordero.

  @author Totvs Nordeste
  Return
/*/
// -----------------------------------------
Static Function fnGerBor(nY)
  Local aBanco  := StrTokArr(aTitM460[nY][01],";")
  Local cEspec  := "" 
  Local aRegBor := {}
  Local aRegTit := {}
  Local nX
  
  Private lMsErroAuto    := .F.
  Private lMsHelpAuto    := .T.
  Private lAutoErrNoFile := .T.

 // -- Informações bancárias para o borderô
 // ---------------------------------------

  DBSelectArea("F77")
  IF F77->(MsSeek(FWxFilial("F77")+aBanco[01]))
    While ! F77->(Eof()) .AND. F77->F77_BANCO == aBanco[01]
      If F77->F77_SIGLA == PadR('DM',FWTamSX3("F77_SIGLA")[1]) 
        cEspec := F77->F77_ESPECI
        Exit
      EndIF 
      F77->(DBSkip())
    End 
  EndIf 

  aAdd(aRegBor, {"AUTBANCO"   , aBanco[01]})
  aAdd(aRegBor, {"AUTAGENCIA" , aBanco[02]})
  aAdd(aRegBor, {"AUTCONTA"   , aBanco[03]})
  aAdd(aRegBor, {"AUTSITUACA" , PadR("1",FWTamSX3("E1_SITUACA")[1])})
  aAdd(aRegBor, {"AUTNUMBOR"  , PadR("",FWTamSX3("E1_NUMBOR")[1])}) // Caso não seja passado o número será obtido o próximo pelo padrão do sistema
  aAdd(aRegBor, {"AUTSUBCONTA", aBanco[04]})
  aAdd(aRegBor, {"AUTESPECIE" , cEspec})
  aAdd(aRegBor, {"AUTBOLAPI"  , .T.})

  For nX := 2 To Len(aTitM460[nY])
    aAdd(aRegTit, aTitM460[nY][nX][1])
  Next

  MsExecAuto({|a,b| FINA060(a,b)},3,{aRegBor, aRegTit})

  If lMsErroAuto
    MostraErro()
  EndIf

Return
