#Include 'Protheus.ch'
#Include "Totvs.ch"
#Include "TBICONN.ch"
#Include 'FWMVCDef.ch'

//----------------------------------------------------------
/*/{PROTHEUS.DOC} OMSA010
Ponto de entrada na rotina de Manutenção de Tabela de Preço
@OWNER MCP
@VERSION PROTHEUS 12
@SINCE 04/12/2024
/*/
User Function OMSA010()
	Local aArea    	:= FWGetArea()
	Local aParam   	:= PARAMIXB
	Local xRet     	:= .T.
	Local oObj     	:= Nil
	Local oFWriter  := Nil
	Local cIdPonto 	:= ""
	Local cIdModel 	:= ""
	Local cLocalArq := GetTempPath(.T.,.F.)
	Local cNomeArq  := ""
	Local lIsGrid  	:= .F.
	Local nOpc

	Private cAliasQry := ""

	If (aParam <> NIL)
		oObj := aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]
		lIsGrid  := (Len(aParam) > 3)
		nOpc := oObj:GetOperation() 
		
		If cIdPonto == "MODELCOMMITNTTS"   	
			If oObj != Nil
				If nOpc == 3 .OR. nOpc == 4

					DBSelectArea("DA1")
					DBSelectArea("SB1")
				
					IF DA1->(MSSeek(xFilial("DA1") + DA0->DA0_CODTAB ))
						cNomeArq := "xml_tabela_preco_"+Lower(StrTran(AllTrim(DA0->DA0_DESCRI)," ","_"))+".xml"
						oFWriter := FWFileWriter():New(cLocalArq + cNomeArq, .T.)
						oFWriter:SetCaseSensitive(.T.)
						IF oFWriter:Create()
							While DA1->(!Eof()) .AND. ( DA1->DA1_FILIAL + DA1->DA1_CODTAB == DA0->DA0_FILIAL + DA0->DA0_CODTAB )
								IF SB1->(MSSeek(xFilial("SB1") + DA1->DA1_CODPRO))
									oFWriter:Write('<row>' + CRLF)
									oFWriter:Write('<enviPSCF>enviPSCF</enviPSCF>' + CRLF)
									oFWriter:Write('<VERSÃO>VERSAO 1.0</VERSÃO>' + CRLF)
									oFWriter:Write('<DADOSDECLARANTE>'+FWFilialName(cEmpAnt,cFilAnt,2)+'</DADOSDECLARANTE>' + CRLF)
									oFWriter:Write('<CNPJ>'+AllTrim(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{"M0_CGC"}))+'</CNPJ>' + CRLF)
									oFWriter:Write('<IEST>'+AllTrim(FWSM0Util():GetSM0Data(cEmpAnt,cFilAnt,{"M0_INSC"}))+'</IEST>' + CRLF)
									oFWriter:Write('<XNOME>'+FWFilialName(cEmpAnt,cFilAnt,2)+'</XNOME>' + CRLF)
									oFWriter:Write('<LISTADEPRODUTOS>lista produtos</LISTADEPRODUTOS>' + CRLF)
									oFWriter:Write('<PRODUTOS>Produtos</PRODUTOS>' + CRLF)
									oFWriter:Write('<CPROD>'+AllTrim(SB1->B1_COD)+'</CPROD>' + CRLF)
									oFWriter:Write('<XPROD>'+AllTrim(SB1->B1_DESC)+'</XPROD>' + CRLF)
									oFWriter:Write('<CEST>'+AllTrim(SB1->B1_CEST)+'</CEST>' + CRLF)
									oFWriter:Write('<NCM>'+AllTrim(SB1->B1_POSIPI)+'</NCM>' + CRLF)
									oFWriter:Write('<cEAN>'+AllTrim(SB1->B1_CODBAR)+'</cEAN>' + CRLF)
									oFWriter:Write('<cEANTRIB>'+AllTrim(SB1->B1_CODBAR)+'</cEANTRIB>' + CRLF)
									oFWriter:Write('<uCom>'+AllTrim(SB1->B1_CODBAR)+'</uCom>' + CRLF)
									oFWriter:Write('<uTRIB>'+AllTrim(SB1->B1_CODBAR)+'</uTRIB>' + CRLF)
									oFWriter:Write('<cUF>'+AllTrim(DA1->DA1_ESTADO)+'</cUF>' + CRLF)
									oFWriter:Write('<vUntrib>'+AllTrim(cValtoChar(DA1->DA1_PRCVEN))+'</vUntrib>' + CRLF)
									oFWriter:Write('<INIC_TAB>'+IIF(!Empty(DA1->DA1_USERGA),FWLeUserlg("DA1_USERGA", 2),FWLeUserlg("DA1_USERGI", 2))+'</INIC_TAB>' + CRLF)
									oFWriter:Write('<INIC_TAB_ANTERIOR>'+FWLeUserlg("DA1_USERGI", 2)+'</INIC_TAB_ANTERIOR>' + CRLF)
									oFWriter:Write('</row>' + CRLF)
								ENdIF 
								DA1->(DBSkip())
							EndDo
						oFWriter:Close()
						ShellExecute("open", cNomeArq, "", cLocalArq, 1)
						EndIF
					EndIF 

				EndIf 	
			EndIf
		EndIf 
	EndIf 

	FWRestArea(aArea)
Return xRet
