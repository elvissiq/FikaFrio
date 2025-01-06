#Include "TOTVS.ch"
#Include "RESTFUL.ch"
#Include "Protheus.ch"
#Include "FWMVCDEF.ch"

// ----------------------------------------------------
/*/ Rotina FFWSVW03

    WebService REST para integração PROTHEUS x SOVIS 

  @param Recebe parámetros (Requisição em REST)
  @retorno Confirmação
  @author Anderson Almeida (TOTVS NE)
  @since   29/08/2024 - Desenvolvimento da Rotina.
/*/
// ----------------------------------------------------
WsRestFul FFWSVW03 Description "API Generica Protheus"
  WsMethod Get Cons_SQL;
    Description "Consulta via SQL";
    WSSYNTAX "/api/retail/v1/FFWSVW03/Cons_SQL";
    PATH "/api/retail/v1/FFWSVW03/Cons_SQL";
    PRODUCES APPLICATION_JSON;
    TTALK "v1"

  WsMethod Post Ped_Venda;
    Description "Pedio de Venda";
    WSSYNTAX "/api/retail/v1/FFWSVW03/Ped_Venda";
    PATH "/api/retail/v1/FFWSVW03/Ped_Venda";
    PRODUCES APPLICATION_JSON;
    TTALK "v1"
End WsRestFul

//------------------------------------------------------
/*/ Método Get Cons_SQL

    Ler os dados da tabela requisitada via sentença
    SQL.

  @author Anderson Almeida (TOTVS NE)
  @since 29/08/2024	
/*/
//------------------------------------------------------
WsMethod Get Cons_SQL WsReceive WsService FFWSVW03
  Local lRet     := .F.
  Local nPos     := 0
  Local oJSon	   := THashMap():New()
  Local cJSonRet := ""
  Local cMsg     := ""
  Local cBody    := ""
  Local xValor

  ::SetContentType("application/json")

  cBody := Self:GetContent()
  lRet  := FWJsonDeserialize(cBody, @oJSon)

  If ! lRet
     cMsg := "ERRO JSon."
   else 
     Do Case
        Case ! AttIsMemberOf(oJSon, "id")
             cMsg := "ID Rotina não enviado."
	         lRet := .F.

        Case ! AllTrim(oJSon:id) == "SQL"
             cMsg := "ID enviado inválido."
	         lRet := .F.
        
        Case ! AttIsMemberOf(oJSon, "opcao")
             cMsg := "Opção não enviada."
	         lRet := .F.

        Case ! oJSon:opcao == 2
             cMsg := "Opção enviada inválida."
	         lRet := .F.

        Case ! AttIsMemberOf(oJSon, "query")
             cMsg := "Sentença SQL não enviada."
             lRet := .F.
     EndCase
  EndIf

  If lRet
	   cQry := ChangeQuery(oJSon:query)
	   dbUseArea(.T.,"TopConn",TcGenQry(,,cQry),"TMP")

     cJSonRet := '{'
     cJSonRet += ' "status": 201,'
     cJSonRet += ' "msg":'
     cJSonRet += '  {'
     cJSonRet += '   "retorno":'
     cJSonRet += '    ['

     If TMP->(Eof())
        cJSonRet += '     "Alerta": "Não existe registro para essa consulta."'
     EndIf

     While ! TMP->(Eof())
       nPos     := 1
       cJSonRet += '     {'

       While ! Empty(FieldName(nPos))
         If ValType(&("TMP->" + FieldName(nPos))) == "N"
            xValor := Str(&("TMP->" + FieldName(nPos)))
          else
            xValor := &("TMP->" + FieldName(nPos))
         EndIf

         cJSonRet += '     "' + FieldName(nPos) + '": "' + AllTrim(xValor) + '"'
 
         nPos++

         If ! Empty(FieldName(nPos))
            cJSonRet += ','
         EndIf
       EndDo

       TMP->(dbSkip())
       
       cJSonRet += '     }' + IIf(TMP->(Eof()),'',',') 
     EndDo

     TMP->(dbCloseArea())

     cJSonRet += '    ]'
     cJSonRet += '  }'
     cJSonRet += '}'
  EndIf

  If ! lRet
     SetRestFault(400, EncodeUTF8(cMsg))
   else
	   ::SetResponse(EncodeUTF8(cJSonRet))	
  EndIf
Return lRet

//------------------------------------------------------
/*/ Método Post Ped_Venda
  
    Post gravação de inclusão, alteraça e exclusão de
    Contas a Receber.

  @since 11/09/2024	
/*/
//------------------------------------------------------
WsMethod Post Ped_Venda WsReceive WsService FFWSVW03
  Local oJson	   := THashMap():New()
  Local cMensag  := ""
  Local cJSon    := ""
  Local cJSonRet := ""
  Local lRet     := .T.

  ::SetContentType("application/json")

  cBody := Self:GetContent()
  lRet  := FWJsonDeserialize(cBody, @oJSon)

  If lRet
	   lRet := fnGrvReg(@oJSon, @cJSon, @cMensag)

	   cJsonRet := '{ "Ret": ['
	   cJsonRet += cJSon
	   cJsonRet += '] }'
   else	
	   cMensag := "JSon Error"	
  EndIf

  If ! lRet
     SetRestFault(400, cMensag)
   else
	   ::SetResponse(cJSonRet)	
  EndIf
Return lRet

//-----------------------------------------------------
/*/ Funçoa fnGrvReg

   Leitura e gravação dos registros.

  @param: oJSon	 , objeto
          cJSon  , String - JSon Retorno
  	      cMensag, String - Msg Retorno
	
  @Retorno lOk , logico		

  @author Anderson Almeida (TOTVS Ne)
  @since   11/09/2022 - Desenvolvimento da Rotina.
/*/
//-----------------------------------------------------
Static Function fnGrvReg(oJson, cJSon, cMensag)
  Local lOk	  	 := .T.
  Local aRet     := {.T.,{}}
  Local aRegSC5  := {}
  Local aRegSC6  := {}
  Local aAux     := {}
  Local nX       := 0
  Local nY       := 0
  Local nK       := 0
  Local nOpcao   := 0
  Local cChar    := ""
  Local cAux     := ""
  Local cCNPJFil := ""
  Local cLog	   := ""
  Local cJSonAux := ""
  Local cCliente := ""
  Local cLoja    := ""
  Local cProduto := ""
  Local cOper    := ""
  Local cTES     := ""
  Local oItem    := Nil

  Private aDados         := {}
  Private aRegJson       := {}
  Private aHeader        := {}
  Private aCols          := {} 
  Private cFilAnt        := ""
  Private cEmpAnt        := ""
  Private cLogError      := ""
  Private cIDRot         := ""
  Private lMsErroAuto    := .F.
  Private lMsHelpAuto    := .T.
  Private lAutoErrNoFile := .T.

 // -- Validar envio CNPJ Empresa
 // ----------------------------- 
  If AttIsMemberOf(oJSon, "company")	
     cCNPJFil := oJSon:company
     lOk      := fnPegFil(@cCNPJFil, @cMensag)   // -- Pegar código e filial da empresa
	 else
     cMensag += "CNPJ da empresa não enviado. "
     lOk     := .F.
  EndIf

	If lOk
     If AttIsMemberOf(oJSon, "id") 	
	      cIDRot := oJSon:id
	    else
	      cMensag += "ID Rotina não enviado. " + CLRF
        lOk     := .F.
     EndIf

     If lOk
        If AttIsMemberOf(oJSon, "opcao") 	
	         nOpcao := oJSon:opcao
	       else
		       cMensag += "OPCAO não enviado. " + CLRF
           lOk     := .F.
        EndIf	
     EndIf

    // -- Ler o dados do JSon  
    // ----------------------
     If lOk
        If AttIsMemberOf(oJSon, "itens") 
	         oItem  := oJSon:itens  
	         aDados := {}

	         For nX := 1 To len(oItem) 
		           aRet := fnMntReq(oItem[nX])
		           lOk  := aRet[01]

		           If ! lOk
		              Exit	
		           EndIf   

		           aAdd(aDados, {aRet[02],;    // 01 - Cabeçalho
                             aRet[03]})    // 02 - Itens
	         Next
         else
           lOk := .F.
        EndIf
     EndIf
  EndIf

  If ! lOk
  	 cMensag += "ERRO na estrutura da requisicao."
  EndIf

  If lOk
     dbSelectArea("SC5")
     SC5->(dbSetOrder(1))

	   For nX := 1 To Len(aDados)
         lMsErroAuto := .F.
	 	     aCab 		   := aDados[nX][01]
		     aItens		   := aDados[nX][02]
         cLog        := ""

         If cIDRot == "MATA410"
            aRegSC5 := {}
            aRegSC6 := {}
    
           // -- Validar o Pedido
           // -------------------
            If nOpcao <> 3
               If (nPos := aScan(aCab, {|x| AllTrim(x[01]) == "C5_NUM"})) == 0
                  cLog := "Tag C5_NUM não foi informada."
                else
                  If ! SC5->(dbSeek(FWxFilial("SC5") + aCab[nPos][02]))
                     cLog := "Pedido de Venda " + AllTrim(aCab[nPos][02]) + " nao encontrado."
                   else
                     cQuery := "Select SC9.C9_NFISCAL, SC9.C9_SERIENF"
                     cQuery += "  from " + RetSqlName("SC9") + " SC9"
                     cQuery += "   where SC9.D_E_L_E_T_ <> '*'"
                     cQuery += "     and SC9.C9_FILIAL  = '" + FWxFilial("SC9") + "'"
                     cQuery += "     and SC9.C9_PEDIDO  = '" + aCab[nPos][02] + "'"
                     cQuery += "     and SC9.C9_NFISCAL <> ''"
                     cQuery := ChangeQuery(cQuery)
                     dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"QSC9",.F.,.T.)

                     If ! QSC9->(Eof())
                        cLog := "Pedido de Venda " + AllTrim(aCab[nPos][02]) + " ja faturado, Serie/Nota Fiscal " +;
                                AllTrim(QSC9->C9_SERIENF) + " / " + QSC9->C9_NFISCAL  
                     EndIf   

                     QSC9->(dbCloseArea())
                  EndIf
               EndIf
//             else
//               aAdd(aRegSC5, {"C5_NUM", GetSX8Num("SC5","C5_NUM"), Nil})  
            EndIf      
           // ----------------------

            If Empty(cLog)
               For nY := 1 To Len(aCab)
                   aAdd(aRegSC5, {aCab[nY][01] , aCab[nY][02], Nil})

                   If aCab[nY][01] == "C5_CLIENTE"
                      cCliente := aCab[nY][02]

                    elseIf aCab[nY][01] == "C5_LOJACLI"
                           cLoja := aCab[nY][02]
                   EndIf 
               Next   

               If Empty(cCliente) .or. Empty(cLoja)
                  cLog := "Requisição com problema, falta informar a tag 'C5_CLIENTE' ou 'C5_LOJACLI'."
                else
                  For nY := 1 To Len(aItens)
                      aAux := {}

                      For nK := 1 To Len(aItens[nY]) 
                          aAdd(aAux, {aItens[nY][nK][01], aItens[nY][nK][02], Nil})

                          If aItens[nY][nK][01] == "C6_PRODUTO"
                             cProduto := aItens[nY][nK][02]

                           elseIf aItens[nY][nK][01] == "C6_OPER"
                                  cOper := AllTrim(aItens[nY][nK][02]) 
                          EndIf    
                      Next
         
                     // -- Achar a TES
                     // --------------
                      cTES := MaTESInt(2,cOper,cCliente,cLoja,"C",cProduto,"C6_TES")

                      aAdd(aAux, {"C6_TES", cTES, Nil})
                     // -------------- 

                      aAdd(aRegSC6, aAux)
                  Next
               
                  Begin Transaction
                    MsExecAuto({|x,y,Z| MATA410(x,y,z)}, aRegSC5, aRegSC6, nOpcao)

                    If lMsErroAuto
			                 aAux := GetAutoGRLog()

			                 For nY := 1 To Len(aAux)
				                   cAux := AllTrim(aAux[nY])
				                   cLog += cAux
			                 Next

                       For nY := 1 To Len(cLog)
	                         cChar := SubStr(cLog,nY,1)

                           If (Asc(cChar) < 32 .Or. Asc(cChar) > 123) .and. !cChar $ "|"
		                          cLog := StrTran(cLog,cChar," ")
	                         EndIf
                       Next 
                    
                       DisarmTransaction()
//                     else
//                       ConfirmSX8()  
                    EndIf
			            End Transaction
               EndIf
            EndIf  
         EndIf

         If ! Empty(cLog)
            cLogError += EncodeUTF8(cLog)
			      cJSonAux  := ""
			      cJSonAux  += '{ "status" : 401,'
			      cJSonAux  += '  "msg" : "' + cLogError + '" }'
          else
      			cJSonAux := ""
			      cJSonAux += '{ "status" : 201,'
            cJSonAux += '  "pedido" : "' + SC5->C5_NUM + '",'  
			      cJSonAux += '  "msg" : "sucesso" }'
         EndIf

      	 cJSon += cJSonAux

		     If nX < Len(aDados)
			      cJSon += ","
		     EndIf
     Next
  EndIf
Return lOk

//--------------------------------------------------------
/*/ Função fnMntReg

   Montar o array com registrosa requisição.

  @Parametro oItem, objeto
  @Retorno lOk	, logico
           aRegJson, matriz com os dados da requisiÃ§Ã£o
  @since
   01/07/2021 - Desenvolvimento da rotina.
/*/
//--------------------------------------------------------
Static Function fnMntReq(oItemReq)
  Local lRet    := .T.
  Local aStruc  := {}
  Local aRet    := {}
  Local aRJson1 := {}
  Local aRJson2 := {}
  Local cCampo  := ""
  Local cValor  := "" 
  Local cAlias  := ""
  Local nX      := 0
  Local nPos    := 0
  Local oData

  If AttIsMemberOf(oItemReq,"tab")
     cAlias := oItemReq:tab
     aStruc := (cAlias)->(dbStruct())
   else
     lRet := .F.
  EndIf	

  If lRet .and. AttIsMemberOf(oItemReq,"data")
     oData := oItemReq:data
   else
     lRet := .F.
  EndIf			

  If lRet 
     If (nPos := aScan(aStruc, {|x| x[01] $ "_FILIAL"})) > 0 
        aAdd(aRJson1, {aStruc[nPos][01], FWxFilial(cAlias)})
     EndIf

     For nX := 1 To Len(oData)
 	       If AttIsMemberOf(oData[nX], "SubItem1")
  		      aRet := fnLerReq(oData[nX]:SubItem1)

		        If aRet[01]
               aRJson2 := aRet[02]

               Exit  
            EndIf   

			    else		
            nPos := aScan(aStruc, {|x| AttIsMemberOf(oData[nX], Upper(AllTrim(x[01])))})
         
            If nPos > 0
               cCampo := Lower(aStruc[nPos][01])
               cValor := &("oData[nX]:" + AllTrim(cCampo))
               xValor := fnVldCpo(cCampo, cValor, aStruc[nPos][02], aStruc[nPos][03])

               aAdd(aRJson1, {Upper(cCampo),;       // 01 - Nome do campo
                              xValor})              // 02 - Conteúdo do campo
            EndIf
	       EndIf
     Next
  EndIf	 
Return {lRet, aRJson1, aRJson2}

//------------------------------------------------------------------
/*/ Função fnLerReq

    Retorna o array com o registro para manutenção Pedido de Venda.

  @parametro oItem, objeto
  @retorrno lOk	, logico
            aRegJson, matriz com os dados da requisição
  @since    12/09/2024 - Desenvolvimento da rotina.
/*/
//------------------------------------------------------------------
Static Function fnLerReq(oSubItReq)
  Local lRet    := .T.
  Local aStruc  := {}
  Local aRetSub := {}
  Local aRJson  := {}
  Local cCampo  := ""
  Local cValor  := "" 
  Local cAlias  := ""
  Local nId     := 0
  Local nId1    := 0
  Local nPos    := 0
  Local oData

  For nId := 1 to Len(oSubItReq)
  If AttIsMemberOf(oSubItReq[nId],"tab")
     cAlias := oSubItReq[nId]:tab
     aStruc := (cAlias)->(dbStruct())
   else
     lRet := .F.
  EndIf	

  If lRet .and. AttIsMemberOf(oSubItReq[1],"data")
     oData := oSubItReq[nId]:data
   else
     lRet := .F.
  EndIf			

  If lRet
     aRJson := {}

     If (nPos := aScan(aStruc, {|x| x[01] $ "_FILIAL"})) > 0 
        aAdd(aRJson, {aStruc[nPos][01],;     // 01 - Nome do campo
                      FWxFilial(cAlias)})    // 02 - Conteúdo do campo
     EndIf
 					
     For nId1 := 1 To Len(oData)
         nPos := aScan(aStruc, {|x| AttIsMemberOf(oData[nId1], Upper(AllTrim(x[01])))})
         
         If nPos > 0
            cCampo := Lower(aStruc[nPos][01])
            cValor := &("oData[nId1]:" + AllTrim(cCampo))
            xValor := fnVldCpo(cCampo, cValor, aStruc[nPos][02], aStruc[nPos][03])    

            aAdd(aRJson, {Upper(cCampo),;    // 01 - Nome do campo
                          xValor})           // 02 - Conteúdo do campo
         EndIf
     Next

     aAdd(aRetSub, aRJson)
  EndIf
  Next	 
Return {lRet, aRetSub}

//--------------------------------------------------------------
/*/ Função fnVldCpo

    Conversção do campo para a caracterí­stica do campo na base
    de dados.

  @Parametro oItem, objeto
  @Retorrno cCampo   - Nome do campo
            xValor   - ConteÃºdo do campo
            cTipDad  - CaracterÃ­stica do campo
            nTamanho - Tamando do campo

  @since 12/09/2024 - Desenvolvimento da rotina.
/*/
//--------------------------------------------------------------
Static Function fnVldCpo(cCampo, xValor, cTipDad, nTamanho)
  Local xConverte := ""
  Local aGetCmp	  := IIf(! Empty(cCampo),Separa(cCampo,"_"),{})

  Default cTipDad := ""

  Do Case
	  // -- Converte para númerico
    // -------------------------
	   Case (! Empty(cTipDad) .and. cTipDad == "N") .or. (Len(aGetCmp) == 2 .and. FWTamSX3(cCampo)[03] == "N")
		      Do Case
			       Case ValType(xValor) == "C"			
				          xValor    := StrTran(xValor,",",".")				
				          xConverte := Val(xValor)

			       Case ValType(xValor) == "N"
				          xConverte := xValor	
			
             OtherWise
				          xConverte := 0
		      EndCase

  	// -- Converte para data
    // ---------------------
	   Case (! Empty(cTipDad) .and. cTipDad == "D") .or. (Len(aGetCmp) == 2 .and. FWTamSX3(cCampo)[03] == "D")	
		      xConverte := IIf(!Empty(AllTrim(xValor)),CtoD(xValor),CtoD(""))
		
	  // -- Converte para String
    // -----------------------		
	   Case (! Empty(cTipDad) .and. cTipDad == "C") .or. (Len(aGetCmp) == 2 .and. TamSX3(cCampo)[03] == "C")	
		      If Empty(cTipDad)
			       xConverte := PadR(xValor, TamSX3(cCampo)[01])
		       else
			       xConverte := PadR(xValor, nTamanho)
		      EndIf
			
	  // -- Converte Memo
    // ----------------
	   Case (! Empty(cTipDad) .and. cTipDad == "M") .or. (Len(aGetCmp) == 2 .and. FWTamSX3(cCampo)[03] == "M")
		      xConverte := xValor	
  EndCase
Return xConverte

//--------------------------------------------------------
/*/ Função fnPegFil

    Rotina que busca o código da filial baseado no CNPJ.

  @param: cCnpjFil, character
  @Author Anderson Almeida (TOTVS Ne)
  @since   11/09/2024 - Desenvolvimento da rotina.
/*/
//--------------------------------------------------------
Static Function fnPegFil(cCNPJFil, cMensag)
  Local lRet    := .T.
	Local cCodEmp := ""
  Local cCodFil := ""

  OpenSM0("01")
			
  SM0->(dbGoTop())

  While ! SM0->(Eof())
		If AllTrim(SM0->M0_CGC) == cCNPJFil
		   cCodFil := AllTrim(SM0->M0_CODFIL)
		   cCodEmp := AllTrim(SM0->M0_CODIGO)

		   Exit
		EndIf

		SM0->(dbSkip())
  EndDo
		
  If Empty(AllTrim(cCodFil))
     lRet    := .F.
     cMensag := "Não foi possível carregar a filial com o CNPJ informado! "
   else
	   If Type("cEmpAnt") == "U" .or. ! (cEmpAnt == cCodEmp .and. cFilAnt == cCodFil)
		    If IsBlind()
		       RpcSetType(3)
	         RpcSetEnv(cCodEmp, cCodFil)
		    EndIf

		    cEmpAnt := cCodEmp
		    cFilAnt	:= cCodFil
	   EndIf		
  EndIf
Return lRet
