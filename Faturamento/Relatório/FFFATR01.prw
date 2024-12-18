#Include "TOTVS.ch"
#Include "PROTHEUS.ch"
#Include "TOPCONN.ch"
#Include "FWPRINTSETUP.CH"
#Include "RPTDEF.CH"
#Include "FWADAPTEREAI.CH"

//---------------------------------------------------------
/*/ Rotina FFFATR01
  
    Impressão de Pedido de Venda em impressora não fiscal.

  @author Anderson Almeida (TOTVS)
  @since   21/10/2024 - Desenvolvimento da Rotina.
/*/
//----------------------------------------------------------
User Function FFFATR01()
  If MsgYesNo("Confirmar impressão da Amarelinha do Pedido " + SC5->C5_NUM + " ?" )
     MsAguarde({|| ImprPV()},"Processando...")
  EndIf
Return

//--------------------------------------------------
/*/ Rotina ImprPV
  
    Impressão do Pedido de Venda.

  @author Anderson Almeida (TOTVS)
  @since   21/10/2024 - Desenvolvimento da Rotina.
/*/
//--------------------------------------------------
Static Function ImprPV()
  Local aArea     := FWGetArea()
  Local nPos      := 0
  Local nMaxChar  := 87           // Máximo de caracteres por linha
  Local nTtPedido := 0
  Local nTtDesc   := 0
  Local nTtIPI    := 0
  Local nTtICMSST := 0
  Local nTotal    := 0
  Local nTtFin    := 0
  Local aRetImp   := 0
  Local aGrupo    := {}
  Local aRegSC6   := {}
  Local aParcelas := {}
  Local aItePed   := {}
  Local cQry      := ""
  Local cDesc     := ""
  Local cLogo     := GetSrvProfString("Startpath","") + "lgmid01.png"
	Local oFont8  	:= TFont():New("Arial",9,08,.T.,.F.,5,.T.,5,.T.,.F.)
	Local oFont11n 	:= TFont():New("Arial",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
	Local oFont10  	:= TFont():New("Arial",9,10,.T.,.F.,5,.T.,5,.T.,.F.)
	Local oFont10n 	:= TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
  Local oPrint

  dbSelectArea("SA1")
  SA1->(dbSetOrder(1))
  
  If ! SA1->(dbSeek(FWxFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI))
     ApMsgInfo("Cliente não encontrado.")

     Return
  EndIf

 // -- Impressão dos itens
 // ----------------------
  cQry := "Select SC9.C9_ITEM, SC9.C9_PRODUTO, SC9.C9_QTDLIB, SC9.C9_PRCVEN, SC9.C9_LOTECTL,"
  cQry += "       SC6.C6_TES, SC6.C6_NFORI, SC6.C6_SERIORI, SC6.C6_VALOR, SC6.C6_VALDESC,"
  cQry += "       SB1.B1_DESC, SB1.B1_GRUPO, SBM.BM_DESC"
  cQry += "  from " + RetSQLName("SC9") + " SC9, " + RetSQLName("SC6") + " SC6, " + RetSQLName("SB1") + " SB1"
  cQry += "   Left Join " + RetSQLName("SBM") + " SBM"
  cQry += "          on SBM.D_E_L_E_T_ <> '*'"
  cQry += "         and SBM.BM_FILIAL = '" + FWxFilial("SBM") + "'"
  cQry += "         and SBM.BM_GRUPO  = SB1.B1_GRUPO"
  cQry += "   where SC9.D_E_L_E_T_ <> '*'"
  cQry += "     and SC9.C9_FILIAL = '" + FWxFilial("SC9") + "'"
  cQry += "     and SC9.C9_PEDIDO = '" + SC5->C5_NUM + "'"
//  cQry += "     and SC9.C9_BLEST  = ''"
  cQry += "     and SC6.D_E_L_E_T_ <> '*'"
  cQry += "     and SC6.C6_FILIAL = '" + FWxFilial("SC6") + "'"
  cQry += "     and SC6.C6_NUM    = SC9.C9_PEDIDO"
  cQry += "     and SC6.C6_ITEM   = SC9.C9_ITEM"
  cQry += "     and SB1.D_E_L_E_T_ <> '*'"
  cQry += "     and SB1.B1_FILIAL = '" + FwxFilial("SB1") + "'"
  cQry += "     and SB1.B1_COD    = SC9.C9_PRODUTO"
  cQry := ChangeQuery(cQry)
  dbUseArea(.T.,"TopConn",TCGenQry(,,cQry),"QSC9",.F.,.T.)

  If QSC9->(Eof())
     ApMsgInfo("Pedido Bloqueado ou Encerrado.")

     QSC9->(dbCloseArea())

     FWRestArea(aArea)

     Return
  EndIf 

  While ! QSC9->(Eof())
    If (nPos := aScan(aGrupo,{|x| x[01] == QSC9->B1_GRUPO})) == 0
       aAdd(aGrupo, {QSC9->B1_GRUPO,;    // 01 - Código do Grupo
                     QSC9->BM_DESC,;     // 02 - Descrição do Grupo
                     QSC9->C9_QTDLIB})   // 03 - Quantidade do produto
     else
       aGrupo[nPos][03] += QSC9->C9_QTDLIB
    EndIf

    aAdd(aItePed, {QSC9->C9_ITEM,;          // 01 - Item
                   QSC9->B1_DESC,;          // 02 - Descrição do Produto
                   QSC9->C9_QTDLIB,;        // 03 - Quantidade do Produto
                   QSC9->C9_PRCVEN,;        // 04 - Preço de venda
                   QSC9->C6_VALDESC,;       // 05 - Valor do desconto
                   QSC9->C6_VALOR,;         // 06 - Valor total do item
                   QSC9->C9_LOTECTL})       // 07 - Número do lote 

    nTtDesc   += QSC9->C6_VALDESC
    nTtPedido += QSC9->C6_VALOR

    aAdd(aRegSC6,{QSC9->C9_PRODUTO,;
                  QSC9->C6_TES,;
                  QSC9->C9_QTDLIB,;
                  QSC9->C9_PRCVEN,;
                  QSC9->C6_VALDESC,;
                  QSC9->C6_NFORI,;
                  QSC9->C6_SERIORI,;
                  QSC9->C6_VALOR})

    QSC9->(dbSkip())
  EndDo

  QSC9->(dbCloseArea()) 

  aParcelas := Condicao(nTtPedido,SC5->C5_CONDPAG,,SC5->C5_EMISSAO)    // Pegar as parcelas
  aRetImp   := PegImpos(aRegSC6)                                       // Pegar os impostos
  nTtICMSST := aRetImp[01]
  nTtIPI    := aRetImp[02]
  nTotal    := aRetImp[03]

	oPrint:= TMSPrinter():New("Amarelinha")

	oPrint:StartPage()
  oPrint:SayBitmap(01,280,cLogo,280,180)

  nLin := 200
  oPrint:Say(nLin,002,"PV " + SC5->C5_NUM, oFont11n)
  oPrint:Say(nLin+20,580,DToC(dDataBase) + Space(1) + Time(), oFont8)

  nLin += 70
  oPrint:Say(nLin,002,IIf(! Empty(SA1->A1_XROTA),SubStr(Posicione("Z02",1,FWxFilial("Z02") + SA1->A1_XROTA,"Z02_DESCRI"),1,20),""), oFont8)
  oPrint:Say(nLin,350,AllTrim(SA1->A1_BAIRRO), oFont8)

  nLin += 50
  oPrint:Say(nLin,02,AllTrim(SA1->A1_MUN), oFont8)

  nLin += 50
  oPrint:Say(nLin,02,SC5->C5_CLIENTE + "/" + SC5->C5_LOJACLI + Space(2) + SubStr(SC5->C5_XNOME,1,34), oFont8)

  nLin += 50
  oPrint:Say(nLin,02,"Fantasia " + AllTrim(SA1->A1_NREDUZ), oFont8)

  nLin += 50
  oPrint:Say(nLin,02,AllTrim(SA1->A1_END), oFont8)
  
  nLin += 50
  oPrint:Say(nLin,02,"Fone " + Transform(SA1->A1_TEL,"@R 9999-9999"), oFont8)

  nLin += 50
  oPrint:Say(nLin,02,"P. Ref. " + AllTrim(SA1->A1_COMPLEM), oFont8)

  nLin += 50
  oPrint:Say(nLin,02,"Vend. " + Posicione("SA3",1,FWxFilial("SA3") + SC5->C5_VEND1,"A3_NOME"), oFont8)

  nLin += 50
  oPrint:Say(nLin,002,"Vencto " + DToC(aParcelas[01][01]), oFont8)
  oPrint:Say(nLin,280,"Cond. Pagto " + Posicione("SE4",1,FWxFilial("SE4") + SC5->C5_CONDPAG,"E4_DESCRI"), oFont8)

  nLin += 50
  oPrint:Say(nLin,02,"It  Descricao" + Space(24) + "Qtde    Unit     Desc    Total", oFont8)

  nLin += 50
  oPrint:Say(nLin,02,Replicate("-", nMaxChar), oFont8)

  For nPos := 1 To Len(aItePed)
      nLin += 50
      oPrint:Say(nLin,002, aItePed[nPos][01] + " " + Substr(aItePed[nPos][02],1,18), oFont8)
      oPrint:Say(nLin,430, AllTrim(Str(aItePed[nPos][03])), oFont8)
      oPrint:Say(nLin,480, Transform(aItePed[nPos][04],"@E 99,999.99"), oFont8)
      oPrint:Say(nLin,600, Transform(aItePed[nPos][05],"@E 9,999.99"), oFont8)
      oPrint:Say(nLin,730, Transform(aItePed[nPos][06],"@E 99,999.99"), oFont8)

      cDesc := AllTrim(Substr(aItePed[nPos][02],26,25))
    
      nLin += 50
      oPrint:Say(nLin,02,IIf(! Empty(cDesc),cDesc + Space(16),"") + "Lote:" + aItePed[nPos][07], oFont8) 
  Next

  nLin += 45
  oPrint:Say(nLin,002,Replicate("-", nMaxChar), oFont8)

  nLin += 50
  oPrint:Say(nLin,380,"VALOR TABELA", oFont8)
  oPrint:Say(nLin,710, Transform(nTtPedido,"@E 99,999.99"), oFont8)

  nLin += 50
  oPrint:Say(nLin,380,"DESCONTO", oFont8)
  oPrint:Say(nLin,710, Transform(nTtDesc,"@E 99,999.99"), oFont8)

  nLin += 50
  oPrint:Say(nLin,380,"IPI", oFont8)
  oPrint:Say(nLin,710, Transform(nTtIPI,"@E 99,999.99"), oFont8)

  nLin += 50
  oPrint:Say(nLin,380,"ICMS SUBST TRIB", oFont8)
  oPrint:Say(nLin,710, Transform(nTtICMSST,"@E 99,999.99"), oFont8)

  nLin += 50
  oPrint:Say(nLin,380,"TOTAL DO PEDIDO", oFont8)
  oPrint:Say(nLin,710, Transform((nTtPedido + nTotal),"@E 99,999.99"), oFont8)

  nLin += 50
  oPrint:Say(nLin,02,"OBS.: ", oFont8)

  If Empty(SC5->C5_COMENT)
     nLin += 40
   else  
     oPrint:Say(nLin,080,Substr(SC5->C5_COMENT,1,100), oFont8)
     
     If ! Empty(SubStr(SC5->C5_COMENT,101,200))
        nLin += 50
        oPrint:Say(nLin,080,Substr(SC5->C5_COMENT,101,200), oFont8)
     EndIf
  
     If ! Empty(SubStr(SC5->C5_COMENT,201,50))
        nLin += 50
        oPrint:Say(nLin,080,Substr(SC5->C5_COMENT,201,50), oFont8)
     EndIf
  EndIf   

 // -- Impressão do Resumo (Grupos)
 // -------------------------------
  nLin += 80
  oPrint:Say(nLin,300,"RESUMO:", oFont10n)

  For nPos := 1 To Len(aGrupo)
      nLin += 45
      oPrint:Say(nLin,020,aGrupo[nPos][02], oFont10n)
      oPrint:Say(nLin,540,Transform(aGrupo[nPos][03],"@E 99,999.99"), oFont10n)
  Next

  nLin += 45
  oPrint:Say(nLin,02,Replicate("-", nMaxChar), oFont8)

  nLin += 40
  oPrint:Say(nLin,10,"CONFIRA COM ATENCAO - EVITE TRANSTORNOS", oFont10)
 
  nLin += 30
  oPrint:Say(nLin,02,Replicate("-", nMaxChar), oFont8)

 // -- Impressão dos títulos abertos
 // --------------------------------
  cQry := "Select SE1.E1_EMISSAO, SE1.E1_VENCREA, SE1.E1_PREFIXO, SE1.E1_NUM,"
  cQry += "       SE1.E1_PARCELA, SE1.E1_TIPO, SE1.E1_SALDO"
  cQry += "  from " + RetSqlName("SE1") + " SE1"
  cQry += "   where SE1.D_E_L_E_T_ <> '*'"
  cQry += "     and SE1.E1_FILIAL  = '" + FWxFilial("SE1") + "'"
  cQry += "     and SE1.E1_CLIENTE = '" + SC5->C5_CLIENTE + "'"
  cQry += "     and SE1.E1_LOJA    = '" + SC5->C5_LOJACLI + "'"
  cQry += "     and SE1.E1_SALDO > 0"
  cQry := ChangeQuery(cQry)
  dbUseArea(.T.,"TopConn",TCGenQry(,,cQry),"QSE1",.F.,.T.)

  If ! QSE1->(Eof())
     nLin += 60
     oPrint:Say(nLin,200,"===>>TÍTULOS EM ABERTO <<===", oFont8)
   
     nLin += 50
     oPrint:Say(nLin,02,Replicate("-", nMaxChar), oFont8)
   
     nLin += 50
     oPrint:Say(nLin,002,"EMISSAO", oFont8)
     oPrint:Say(nLin,190,"VENCTO" , oFont8)
     oPrint:Say(nLin,350,"TÍTULO" , oFont8)
     oPrint:Say(nLin,570,"TP.COB.", oFont8)
     oPrint:Say(nLin,710,"VALOR"  , oFont8)

     nLin += 45
     oPrint:Say(nLin,02,Replicate("-", nMaxChar), oFont8)

     nTtPedido := 0

     While ! QSE1->(Eof())  
       nLin += 50
       oPrint:Say(nLin,002,DToC(SToD(QSE1->E1_EMISSAO)), oFont8)
       oPrint:Say(nLin,190,DToC(SToD(QSE1->E1_VENCREA)), oFont8)
       oPrint:Say(nLin,350,AllTrim(QSE1->E1_PREFIXO) + "-" + AllTrim(QSE1->E1_NUM) + "/" + AllTrim(QSE1->E1_PARCELA), oFont8)
       oPrint:Say(nLin,570,IIf(AllTrim(QSE1->E1_TIPO) == "BOL","Boleto",;
                            IIf(AllTrim(QSE1->E1_TIPO) == "NF","N.Fiscal","")), oFont8)
       oPrint:Say(nLin,730,Transform(QSE1->E1_SALDO,"@E 99,999.99"), oFont8)
     
       nTtFin += QSE1->E1_SALDO

       QSE1->(dbSkip())
     EndDo

     nLin += 45
     oPrint:Say(nLin,02,Replicate("-", nMaxChar), oFont8)

     nLin += 50
     oPrint:Say(nLin,330,"TOTAL EM ABERTO ===>>", oFont8)
     oPrint:Say(nLin,730,Transform(nTtFin,"@E 99,999.99"), oFont8)
  EndIf

  QSE1->(dbCloseArea())
	
  oPrint:EndPage()
	oPrint:Print()

  FWRestArea(aArea)
Return

//--------------------------------------------------
/*/ Função PegImpos
  
    Pegar os impostos do Pedido.

  @author Anderson Almeida (TOTVS)
  @since   13/12/2024 - Desenvolvimento da Rotina.
/*/
//--------------------------------------------------
Static Function PegImpos(aRegSC6)
  Local nX        := 0
  Local nBaseICMS := 0
  Local nTotalST  := 0
  Local nTotIPI   := 0
  Local nTotPed   := 0
  Local nTotFECST := 0             // Fundo de pobreza no ICMS ST

  dbSelectArea("SB1")
  SB1->(dbSetOrder(1))
     
  MaFisIni(SC5->C5_CLIENTE,;                        // 01 - Codigo Cliente/Fornecedor
           SC5->C5_LOJACLI,;                        // 02 - Loja do Cliente/Fornecedor
           IIf(SC5->C5_TIPO $ "D;B", "F", "C"),;    // 03 - C:Cliente , F:Fornecedor
           SC5->C5_TIPO,;                           // 04 - Tipo da NF
           SC5->C5_TIPOCLI,;                        // 05 - Tipo do Cliente/Fornecedor
           MaFisRelImp("MT100", {"SF2","SD2"}),;    // 06 - Relacao de Impostos que suportados no arquivo
           ,;                                       // 07 - Tipo de complemento
           ,;                                       // 08 - Permite Incluir Impostos no Rodape .T./.F.
           "SB1",;                                  // 09 - Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
           "MATA461")                               // 10 - Nome da rotina que esta utilizando a funcao
 
 // -- Montar os itens
 // ------------------
  For nX := 1 To Len(aRegSC6)
      SB1->(dbSeek(FWxFilial("SB1") + aRegSC6[nX][01]))

      MaFisAdd(aRegSC6[nX][01],;     // 01 - Codigo do Produto                    ( Obrigatorio )
               aRegSC6[nX][02],;     // 02 - Codigo do TES                        ( Opcional )
               aRegSC6[nX][03],;     // 03 - Quantidade                           ( Obrigatorio )
               aRegSC6[nX][04],;     // 04 - Preco Unitario                       ( Obrigatorio )
               aRegSC6[nX][05],;     // 05 - Desconto
               aRegSC6[nX][06],;     // 06 - Numero da NF Original                ( Devolucao/Benef )
               aRegSC6[nX][07],;     // 07 - Serie da NF Original                 ( Devolucao/Benef )
               0,;                   // 08 - RecNo da NF Original no arq SD1/SD2
               0,;                   // 09 - Valor do Frete do Item               ( Opcional )
               0,;                   // 10 - Valor da Despesa do item             ( Opcional )
               0,;                   // 11 - Valor do Seguro do item              ( Opcional )
               0,;                   // 12 - Valor do Frete Autonomo              ( Opcional )
               aRegSC6[nX][08],;     // 13 - Valor da Mercadoria                  ( Obrigatorio )
               0,;                   // 14 - Valor da Embalagem                   ( Opcional )
               SB1->(RecNo()),;      // 15 - RecNo do SB1
               0)                    // 16 - RecNo do SF4
  Next

 // -- Pega os valores
 // ------------------
  For nX := 1 To Len(aRegSC6)
      nBaseICMS := MaFisRet(nX,"IT_BASEICM")
      nTotPed   += Round((nBaseICMS * 1) / 100,2)
      nTotFECST += MaFisRet(nX,"IT_VFECPST")
  Next
Alert(MaFisRet(,"NF_BASEICM"))
Alert(MaFisRet(,"NF_BASESOL"))
Alert(MaFisRet(,"NF_VALSOL"))
Alert(nTotFECST)

  nTotalST := MaFisRet(,"NF_VALSOL") - nTotFECST
  nTotIPI  := MaFisRet(,"NF_VALIPI")

  MaFisEnd()
Return {nTotalST, nTotIPI, nTotPed}
