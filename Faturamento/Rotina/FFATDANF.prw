//Bibliotecas
#Include "Protheus.ch"
#Include "TBIConn.ch" 
#Include "Colors.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
   
/*/{Protheus.doc} FFATDANF
Função que gera a danfe de uma nota em uma pasta passada por parâmetro
@author Elvis Siqueira (TOTVS)
@since 09/01/2025
@version 1.0
@param cNota, characters, Nota que será buscada
@param cSerie, characters, Série da Nota
@type function
@example U_FFATDANF("000123ABC", "1")
/*/
User Function FFATDANF(cNota, cSerie)
  Local aOrdem     := {}
  Local aDevice    := {}
  Local cIdEnt 		 := ""
  Local cDevice    := ""
  Local cRelName   := ""
  Local cSession   := GetPrinterSession()
  Local cSpool     := ""
  Local lProssegue := .T.
  Local lAdjust    := .F.
  //Local nFlags     := PD_ISTOTVSPRINTER + PD_DISABLEORIENTATION + PD_DISABLEPREVIEW + PD_DISABLEPAPERSIZE
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

  cIdEnt := GetIdEnt()
  cRelName := "DANFE_"+cIdEnt+Dtos(MSDate())+StrTran(Time(),":","")
  
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
  		RptStatus({|lEnd| IMPROM002(@lEnd,nOrdem, @oPrinter)},"Imprimindo Relatorio...")
  	
    Else
  		MsgInfo("Relatório cancelado pelo usuário.") //"Relatório cancelado pelo usuário."
  		oPrinter:Cancel()
  	EndIf
  	
    oSetup:= Nil
  	oPrinter:= Nil
  EndIf

Return
