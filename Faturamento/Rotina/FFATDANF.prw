//Bibliotecas
#Include "Protheus.ch"
#Include "TBIConn.ch" 
#Include "Colors.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
   
/*/{Protheus.doc} FFATDANF
Função que gera a danfe de uma nota em uma pasta passada por parâmetro
@author Elvis Siqueira (TOTVS)
@since 13/01/2025
@version 1.0
@param cNota, characters, Nota que será buscada
@param cSerie, characters, Série da Nota
@type function
@example U_FFATDANF("000123ABC", "1")
/*/
User Function FFATDANF()
Local aOrdem     := {}
Local aDevice    := {}
Local cIdEnt 	 := ""
Local cDevice    := ""
Local cRelName   := ""
Local cSession   := GetPrinterSession()
Local cSpool     := ""
Local lProssegue := .T.
Local lAdjust    := .F.
Local nFlags     := PD_ISTOTVSPRINTER + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN
Local nLocal     := 1
Local nOrdem     := 1
Local nOrient    := 1
Local nPrintType := 6
Local oPrinter   := Nil
Local oSetup     := Nil

Private aArray   := {}
Private li       := 15
Private nMaxLin  := 0
Private nMaxCol  := 0
Private lItemNeg := .F.

  cIdEnt := RetIdEnti()
  cRelName := "DANFE_"+cIdEnt+FWTimeStamp(1)
  
  cSpool := SuperGetMV("MV_REST",,"\RELATO\")
  If !ExistDir(cSpool) .And. (MakeDir(cSpool) <> 0)
  	lProssegue := .F.
  	MsgAlert("Verifique!" + CHR(10) + CHR(13) +;
  		 	"Atenção não foi possível criar o diretório [" + cSpool + "]" + CHR(10) + CHR(13) +;
  		 	"Crie o diretório [" + cSpool + "] manualmente")
  EndIf

  If lProssegue
  	AADD(aDevice,"DISCO") // 1
  	AADD(aDevice,"SPOOL") // 2
  	AADD(aDevice,"EMAIL") // 3
  	AADD(aDevice,"EXCEL") // 4
  	AADD(aDevice,"HTML" ) // 5
  	AADD(aDevice,"PDF"  ) // 6
  	
	cSession   := GetPrinterSession()
  	cDevice	   := If(Empty(fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.)),"PDF",fwGetProfString(cSession,"PRINTTYPE","SPOOL",.T.))
  	nOrient	   := If(fwGetProfString(cSession,"ORIENTATION","PORTRAIT",.T.)=="PORTRAIT",1,2)
  	nLocal	   := If(fwGetProfString(cSession,"LOCAL","SERVER",.T.)=="SERVER",1,2 )
  	nPrintType := aScan(aDevice,{|x| x == cDevice })

  	oPrinter := FWMSPrinter():New(cRelName, nPrintType, lAdjust, /*cPathDest*/, .T.)

  	oSetup := FWPrintSetup():New (nFlags,cRelName)
  	oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
  	oSetup:SetPropert(PD_ORIENTATION , nOrient)
  	oSetup:SetPropert(PD_DESTINATION , nLocal)
  	oSetup:SetPropert( PD_MARGIN, {60,60,60,60} )
  	oSetup:SetPropert(PD_PAPERSIZE, 2 ) 
  	oSetup:SetOrderParms(aOrdem,@nOrdem)
  	
  	If oSetup:Activate() == PD_OK
  		fwWriteProfString( cSession, "LOCAL"      , If(oSetup:GetProperty(PD_DESTINATION)==1 ,"SERVER"    ,"CLIENT"    ), .T. )
  		fwWriteProfString( cSession, "PRINTTYPE"  , If(oSetup:GetProperty(PD_PRINTTYPE)==2   ,"SPOOL"     ,"PDF"       ), .T. )
  		fwWriteProfString( cSession, "ORIENTATION", If(oSetup:GetProperty(PD_ORIENTATION)==1 ,"PORTRAIT"  ,"LANDSCAPE" ), .T. )
  		
		oPrinter:setCopies(Val(oSetup:cQtdCopia))

		/*
		oPrinter:lServer := oSetup:GetProperty(PD_DESTINATION) == AMB_SERVER
  		oPrinter:SetDevice(oSetup:GetProperty(PD_PRINTTYPE))
  		oPrinter:setCopies(Val(oSetup:cQtdCopia))
  		If oSetup:GetProperty(PD_PRINTTYPE) == IMP_SPOOL
  			oPrinter:nDevice := IMP_SPOOL
  			fwWriteProfString(GetPrinterSession(),"DEFAULT", oSetup:aOptions[PD_VALUETYPE], .T.)
  			oPrinter:cPrinter := oSetup:aOptions[PD_VALUETYPE]
  		Else
  			oPrinter:nDevice := IMP_PDF
  			oPrinter:cPathPDF := oSetup:aOptions[PD_VALUETYPE]
  			oPrinter:SetViewPDF(.T.)
  		Endif

  		oPrinter:SetLandscape()
  		nMaxLin	:= 600
  		nMaxCol	:= 800
		*/
		
		ImpDANFE(@oPrinter,@oSetup,@cIdent)

    Else
  		MsgInfo("Relatório cancelado pelo usuário.") //"Relatório cancelado pelo usuário."
  		oPrinter:Cancel()
  	EndIf
  	
    oSetup:= Nil
  	oPrinter:= Nil
  EndIf

Return

/*/{Protheus.doc} fButtomOk
    Botão OK 
/*/
Static Function fButtomOk()
    lBtOK := .T.
    oDialog:DeActivate()
Retur

/*/{Protheus.doc} ImpDANFE
Função que gera a danfe das notas de uma Carga
@author Elvis Siqueira (TOTVS)
@since 13/01/2025
@version 1.0
@type function
/*/
Static Function ImpDANFE(oPrinter,oSetup,cIdent)
Local oPanel
Local cCargaDe  := Space(FWTamSX3("DAK_COD")[1])
Local cCargaAte := Space(FWTamSX3("DAK_COD")[1])
Local oFont     := TFont():New('Arial Black',,-23,.T.)
Local cQry      := ""
Local _cAlias   := GetNextAlias()
Local nTamNota  := TamSX3('F2_DOC')[1]
Local nTamSerie := TamSX3('F2_SERIE')[1]
Local dDataDe   := SToD("20190101")
Local dDataAt   := Date()

Private oDialog  := Nil 
Private lBtOK    := .F.
Private lVerPerg := .F.

	oDialog := FWDialogModal():New()
	oDialog:SetBackground( .T. ) 
	oDialog:SetTitle( 'Informe o código da Carga' )
	oDialog:SetSize( 110, 160 )
	oDialog:EnableFormBar( .T. )
	oDialog:SetCloseButton( .T. )
	oDialog:SetEscClose( .T. )
	oDialog:CreateDialog()
	oDialog:CreateFormBar()
	oDialog:addCloseButton(Nil, "Fechar")
    oDialog:addOkButton({|| fButtomOk() },'Confirmar')

	oPanel := oDialog:GetPanelMain()
			oTSay  := TSay():New(10,5,{|| "Carga De:"},oPanel,,oFont,,,,.T.,,,110,100,,,,,,.T.)
            @ 008,080 MSGET cCargaDe SIZE 050,020 FONT oFont OF oPanel F3 "DAK" PIXEL
			oTSay  := TSay():New(40,5,{|| "Carga Ate:"},oPanel,,oFont,,,,.T.,,,110,100,,,,,,.T.)
            @ 038,080 MSGET cCargaAte SIZE 050,020 FONT oFont OF oPanel F3 "DAK" PIXEL
	oDialog:Activate()

	If lBtOK 
		If !Empty(cCargaAte) .And. !Empty(cCargaAte)
			
			cQry := " SELECT MIN(F2_DOC) AS MINIMO, MAX(F2_DOC) AS MAXIMO, F2_SERIE AS SERIE FROM " + RetSQLName('SF2') + " "
			cQry += " WHERE D_E_L_E_T_ <> '*' " "
			cQry += " 	AND F2_CARGA BETWEEN '" + StrZero(Val(cCargaDe),6) + "' AND '" + StrZero(Val(cCargaAte),6) + "' " 
			cQry += " GROUP BY F2_SERIE "
			cQry := ChangeQuery(cQry)
			IF Select(_cAlias) <> 0
			(_cAlias)->(DbCloseArea())
			EndIf
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),_cAlias,.T.,.T.)

			IF (_cAlias)->(!Eof())
				//Define as perguntas da DANFE
				Pergunte("NFSIGW",.F.)
				MV_PAR01 := PadR((_cAlias)->MINIMO,  nTamNota)  //Nota Inicial
				MV_PAR02 := PadR((_cAlias)->MAXIMO,  nTamNota)  //Nota Final
				MV_PAR03 := PadR((_cAlias)->SERIE ,  nTamSerie) //Série da Nota
				MV_PAR04 := 2                          			//NF de Saida
				MV_PAR05 := 2                          			//Frente e Verso = Nao
				MV_PAR06 := 2                          			//DANFE simplificado = Nao
				MV_PAR07 := dDataDe                    			//Data De
				MV_PAR08 := dDataAt                    			//Data Até

				Do Case
					Case oSetup:oCtlOrientation:NAT == 1 //Retrato
						RptStatus({|lEnd| u_DanfeProc(@oPrinter, @lEnd, @cIdent, , , .F.)}, "Imprimindo Danfe...")
						oPrinter:Print()
					Case oSetup:oCtlOrientation:NAT == 2 //Paisagem
						oPrinter:lInJob := .T.
						RptStatus({|| u_DANFE_P1(@cIdEnt ,/*cVal1*/ ,/*cVal2*/ ,@oPrinter ,@oSetup ,.T.)}, "Imprimindo Danfe...")
				EndCase
			Else
				MsgInfo('Nenhuma nota fiscal encontrada para a(s) carga(s) informada(s).')
			EndIF 
		Else
			MsgInfo('Os campos "Carga De" e "Carga Ate", não podem estar em branco!')
		EndIF 
	Else
		MsgInfo("Relatório cancelado pelo usuário.")
	EndIF 

Return
