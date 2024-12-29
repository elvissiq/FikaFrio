#Include "TOTVS.ch"
#Include "PROTHEUS.ch"
#Include "TOPCONN.ch"
#Include "FWPRINTSETUP.CH"
#Include "RPTDEF.CH"
#Include "FWADAPTEREAI.CH"
#Include 'TBICONN.ch'

//#define DMPAPER_B4 12
// B4 250 x 354
//---------------------------------------------------------
/*/ Rotina FFFATR01
  
    Impressão de Pedido de Venda em impressora não fiscal.

  @author Anderson Almeida (TOTVS)
  @since   21/10/2024 - Desenvolvimento da Rotina.
/*/
//----------------------------------------------------------
User Function FFFATR01()
  Local cPerg := "FFFATR01"

  CriaPerg(@cPerg)
     
  If Pergunte(cPerg,.T.)
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
  Local nMaxChar  := 48           // Máximo de caracteres por linha
  Local nPos      := 0
  Local nTtVenda  := 0
  Local nTtDesc   := 0
  Local nTtIPI    := 0
  Local nTtICMSST := 0
  Local nTtFECST  := 0
  Local nTtPedido := 0
  Local nTtFin    := 0
  Local aGrupo    := {}
  Local aRegSC6   := {}
  Local aParcelas := {}
  Local aCabPed   := {}
  Local aItePed   := {}
  Local aInfoComp := {}
  Local cModImp   := ""
  Local cQry      := ""
  Local cDesc     := ""
  Local cPathRmt  := ""
	Local cPorta		:= "" 
  Local cTexto    := ""
  Local nHdlECF

 // -- Pegar Impressora/Porta no cadastro de Estação
 // ------------------------------------------------ 
  dbSelectArea("SLG") 
  SLG->(dbSetOrder(1))
  
  If ! SLG->(dbSeek(FWxFilial("SLG") + "001"))
     APMsgAlert("Estação '001' não cadastrada nessa filial.")
     
     Return
  EndIf

	cImpressora	:= LjGetStation("IMPFISC")
	cPorta		  := LjGetStation("PORTIF")
  cModImp     := SubStr(cImpressora,1,1)

 // -- Pegar a pasta do SmartClient para impressão da logomarca
 // -----------------------------------------------------------
  aInfoComp := GetRmtInfo()
  cPathRmt  := StrTran(aInfoComp[13],"/","\")
 // ------------------------------------------------------------ 

  dbSelectArea("SA1")
  SA1->(dbSetOrder(1))
  
  If ! SA1->(dbSeek(FWxFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI))
     ApMsgInfo("Cliente não encontrado.")

     Return
  EndIf

 // -- Impressão dos itens
 // ----------------------
  cQry := "Select SC9.C9_CLIENTE, SC9.C9_LOJA, SC9.C9_ITEM, SC9.C9_PRODUTO, SC9.C9_QTDLIB, SC9.C9_PRCVEN,"
  cQry += "       SC9.C9_LOTECTL, SC5.C5_CONDPAG, SC5.C5_EMISSAO, SC5.C5_COMENT, SA1.A1_NOME, SA1.A1_NREDUZ,"
  cQry += "       SA1.A1_XROTA, SA1.A1_END, SA1.A1_COMPLEM, SA1.A1_BAIRRO, SA1.A1_MUN, SA1.A1_TEL, SA3.A3_NOME,"
  cQry += "       SE4.E4_DESCRI, SC6.C6_TES, SC6.C6_NFORI, SC6.C6_SERIORI, SC6.C6_VALOR, SC6.C6_VALDESC, SB1.B1_DESC,"
  cQry += "       SB1.B1_GRUPO, SBM.BM_DESC"
  cQry += "  from " + RetSQLName("SC9") + " SC9"
  cQry += "   Left Join " + RetSQLName("SC5") + " SC5"
  cQry += "          on SC5.D_E_L_E_T_ <> '*'"
  cQry += "         and SC5.C5_FILIAL = '" + FWxFilial("SC5") + "'"
  cQry += "         and SC5.C5_NUM    = SC9.C9_PEDIDO"
  cQry += "   Left Join " + RetSQLName("SA1") + " SA1"
  cQry += "          on SA1.D_E_L_E_T_ <> '*'"
  cQry += "         and SA1.A1_FILIAL = '" + FWxFilial("SA1") + "'"
  cQry += "         and SA1.A1_COD    = SC9.C9_CLIENTE"
  cQry += "         and SA1.A1_LOJA   = SC9.C9_LOJA"
  cQry += "   Left Join " + RetSQLName("Z02") + " Z02"
  cQry += "          on Z02.D_E_L_E_T_ <> '*'"
  cQry += "         and Z02.Z02_FILIAL = '" + FWxFilial("Z02") + "'"
  cQry += "         and Z02.Z02_COD    = SA1.A1_XROTA"
  cQry += "   Left Join " + RetSQLName("SA3") + " SA3"
  cQry += "          on SA3.D_E_L_E_T_ <> '*'"
  cQry += "         and SA3.A3_FILIAL = '" + FWxFilial("SA3") + "'"
  cQry += "         and SA3.A3_COD    = SC5.C5_VEND1"
  cQry += "   Left Join " + RetSQLName("SE4") + " SE4"
  cQry += "          on SE4.D_E_L_E_T_ <> '*'"
  cQry += "         and SE4.E4_FILIAL = '" + FWxFilial("SE4") + "'"
  cQry += "         and SE4.E4_CODIGO = SC5.C5_CONDPAG"
  cQry += ", " + RetSQLName("SC6") + " SC6, " + RetSQLName("SB1") + " SB1"
  cQry += "   Left Join " + RetSQLName("SBM") + " SBM"
  cQry += "          on SBM.D_E_L_E_T_ <> '*'"
  cQry += "         and SBM.BM_FILIAL = '" + FWxFilial("SBM") + "'"
  cQry += "         and SBM.BM_GRUPO  = SB1.B1_GRUPO"
  cQry += "   where SC9.D_E_L_E_T_ <> '*'"
  cQry += "     and SC9.C9_FILIAL = '" + FWxFilial("SC9") + "'"
  cQry += "     and SC9.C9_PEDIDO between '" + mv_par01 + "' and '" + mv_par02 + "'"
//  cQry += "     and SC9.C9_BLEST  = ''"
  cQry += "     and SC6.D_E_L_E_T_ <> '*'"
  cQry += "     and SC6.C6_FILIAL = '" + FWxFilial("SC6") + "'"
  cQry += "     and SC6.C6_NUM    = SC9.C9_PEDIDO"
  cQry += "     and SC6.C6_ITEM   = SC9.C9_ITEM"
  cQry += "     and SB1.D_E_L_E_T_ <> '*'"
  cQry += "     and SB1.B1_FILIAL = '" + FwxFilial("SB1") + "'"
  cQry += "     and SB1.B1_COD    = SC9.C9_PRODUTO"
  cQry += "  Order by SC9.C9_PEDIDO, SC9.C9_ITEM"
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

    If (nPos := aScan(aCabPed,{|x| x[01] == QSC9->C9_PEDIDO})) == 0
       aAdd(aCabPed, {QSC9->C9_CLIENTE,;        // 01 - Código do Cliente
                      QSC9->C9_LOJA,;           // 02 - Loja do Cliente
                      QSC9->A1_NOME,;           // 03 - Nome do Cliente
                      QSC9->A1_NREDUZ,;         // 04 - Nome de fantasia
                      QSC9->A1_XROTA,;          // 05 - Código da Rota
                      QSC9->A1_END,;            // 06 - Endereço do cliente
                      QSC9->A1_COMPLEM,;        // 07 - Complemento do endereço
                      QSC9->A1_BAIRRO,;         // 08 - Bairro
                      QSC9->A1_MUN,;            // 09 - Municipio
                      QSC9->A1_TEL,;            // 10 - Telefone
                      QSC9->A3_NOME,;           // 11 - Nome do vendedor
                      QSC9->C5_CONDPAG,;        // 12 - Condição de pagamento
                      QSC9->E4_DESCRI,;         // 13 - Descrição condição de pagamento
                      SToD(QSC9->C5_EMISSAO),;  // 14 - Emissão do Pedido
                      QSC9->C5_COMENT})         // 15 - Observação do Pedido
    EndIf

    aAdd(aItePed, {QSC9->C9_ITEM,;          // 01 - Item
                   QSC9->B1_DESC,;          // 02 - Descrição do Produto
                   QSC9->C9_QTDLIB,;        // 03 - Quantidade do Produto
                   QSC9->C9_PRCVEN,;        // 04 - Preço de venda
                   QSC9->C6_VALDESC,;       // 05 - Valor do desconto
                   QSC9->C6_VALOR,;         // 06 - Valor total do item
                   QSC9->C9_LOTECTL})       // 07 - Número do lote 

    nTtDesc  += QSC9->C6_VALDESC
    nTtVenda += QSC9->C6_VALOR

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

  For nX := 1 To Len(aCabPed)
      nTtDesc   := 0
      nTtVenda  := 0
      nTtIPI    := 0
      nTtICMSST := 0
      nTtFECST  := 0

      aParcelas := Condicao(nTtPedido,SC5->C5_CONDPAG,,SC5->C5_EMISSAO)    // Pegar as parcelas

  nHdlECF := INFAbrir(cImpressora,cPorta)

  If nHdlECF == -1
	 	APMsgAlert("NFC-e: Não foi possível estabelecer comunicação com a Impressora:" + cImpressora, "ATENÇÃO")

	  Return
  EndIf
  
  If cModImp == "B"
     INFImpBmp(cPathRmt,"lgmid01.bmp")
     cTexto := ""

   elseIf cModImp == "E"
          cTexto := "<ibmp>" + cPathRmt + "lgmid01.bmp" + "</ibmp>"
  EndIf

  cTexto += "<b>PV " + SC5->C5_NUM + "</b>" + Space(20) + "<n>" + DToC(dDataBase) + " " + Time() + "</n>" + Chr(13) + Chr(10)
  cTexto += "<n>" + IIf(! Empty(SA1->A1_XROTA),SubStr(Posicione("Z02",1,FWxFilial("Z02") + SA1->A1_XROTA,"Z02_DESCRI"),1,25),Space(25)) +;
            "  " + AllTrim(SA1->A1_BAIRRO) + "</n>" + Chr(13) + Chr(10)
  cTexto += "<n>" + AllTrim(SA1->A1_MUN) + "</n>" + Chr(13) + Chr(10)
  cTexto += "<n>" + SC5->C5_CLIENTE + "/" + SC5->C5_LOJACLI + " " + SubStr(SC5->C5_XNOME,1,34) + "</n>" + Chr(13) + Chr(10)
  cTexto += "<n>Fantasia " + AllTrim(SA1->A1_NREDUZ) + "</n>" + Chr(13) + Chr(10)
  cTexto += "<n>" + AllTrim(SA1->A1_END) + "</n>" + Chr(13) + Chr(10)
  cTexto += "<n>Fone " + Transform(SA1->A1_TEL,"@R 9999-9999") + "</n>" + Chr(13) + Chr(10)
  cTexto += "<n>P. Ref. " + AllTrim(SA1->A1_COMPLEM) + "</n>" + Chr(13) + Chr(10)
  cTexto += "<n>Vend. " + Posicione("SA3",1,FWxFilial("SA3") + SC5->C5_VEND1,"A3_NOME") + "</n>" + Chr(13) + Chr(10)
  cTexto += "<n>Vencto " + DToC(aParcelas[01][01]) + " "
  cTexto += "Cond. Pagto " + Posicione("SE4",1,FWxFilial("SE4") + SC5->C5_CONDPAG,"E4_DESCRI") + "</n>" + Chr(13) + Chr(10)
  cTexto += "<c>It  Descricao" + Space(21) + "Qtde    Unit     Desc    Total</c>" + Chr(13) + Chr(10)
  cTexto += "<n>" + Replicate("-", nMaxChar) + "</n>" + Chr(13) + Chr(10)

  For nPos := 1 To Len(aItePed)
      cTexto += "<c>" + aItePed[nPos][01] + " " + PadR(Substr(aItePed[nPos][02],1,28),30)
      cTexto += " " + AllTrim(Str(aItePed[nPos][03]))
      cTexto += " " + Transform(aItePed[nPos][04],"@E 99,999.99")
      cTexto += " " + Transform(aItePed[nPos][05],"@E 9,999.99")
      cTexto += " " + Transform(aItePed[nPos][06],"@E 99,999.99")
      cTexto += "</c>" + Chr(13) + Chr(10)

      cDesc := AllTrim(Substr(aItePed[nPos][02],29,30))
    
      cTexto += "<c>" + IIf(! Empty(cDesc),cDesc + Space(02),"") + "Lote:" + aItePed[nPos][07] + "</c>" + Chr(13) + Chr(10)

          nTtDesc  += QSC9->C6_VALDESC
    nTtVenda += QSC9->C6_VALOR

    aAdd(aRegSC6,{QSC9->C9_PRODUTO,;
                  QSC9->C6_TES,;
                  QSC9->C9_QTDLIB,;
                  QSC9->C9_PRCVEN,;
                  QSC9->C6_VALDESC,;
                  QSC9->C6_NFORI,;
                  QSC9->C6_SERIORI,;
                  QSC9->C6_VALOR})
  Next
  PegImpos(@aRegSC6, @nTtIPI, @nTtICMSST, @nTtFECST)                   // Pegar os impostos

  nTtPedido := (nTtVenda + nTtIPI + nTtICMSST + nTtFECST) - nTtDesc


  cTexto += "<n>" + Replicate("-", nMaxChar) + "</n>" + Chr(13) + Chr(10)
  cTexto += "<n>" + Space(18) + PadR("VALOR TABELA",20) + Transform(nTtVenda,"@E 99,999.99") + "</n>" + Chr(13) + Chr(10)
  cTexto += "<n>" + Space(18) + PadR("DESCONTO",20) + Transform(nTtDesc,"@E 99,999.99") + "</n>" + Chr(13) + Chr(10)
  cTexto += "<n>" + Space(18) + PadR("IPI",20) + Transform(nTtIPI,"@E 99,999.99") + "</n>" + Chr(13) + Chr(10)
  cTexto += "<n>" + Space(18) + PadR("ICMS SUBST TRIB",20) + Transform(nTtICMSST,"@E 99,999.99") + "</n>" + Chr(13) + Chr(10)
  cTexto += "<n>" + Space(18) + PadR("TOTAL DO PEDIDO",20) + Transform(nTtPedido,"@E 99,999.99") + "</n>" + Chr(13) + Chr(10)
  cTexto += "<n>" + "OBS.: " + "</n>" + Chr(13) + Chr(10)

  If ! Empty(SC5->C5_COMENT)
     cTexto += "<n>" + PadR(Substr(SC5->C5_COMENT,1,50),50) + "</n>" + Chr(13) + Chr(10)
     
     If ! Empty(SubStr(SC5->C5_COMENT,51,50))
        cTexto += "<n>" + PadR(Substr(SC5->C5_COMENT,51,50),50) + "</n>" + Chr(13) + Chr(10)
     EndIf
  
     If ! Empty(SubStr(SC5->C5_COMENT,101,50))
        cTexto += "<n>" + PadR(Substr(SC5->C5_COMENT,101,50),50) + "</n>" + Chr(13) + Chr(10)
     EndIf
  EndIf   

  cTexto += "<l></l>" + Chr(13) + Chr(10)

 // -- Impressão do Resumo (Grupos)
 // -------------------------------
  cTexto += "<ce>" + "RESUMO:" + "</ce>" + Chr(13) + Chr(10)

  For nPos := 1 To Len(aGrupo)
      cTexto += "<n>" + Space(3) + PadR(aGrupo[nPos][02],30) + Space(3) +;
                Transform(aGrupo[nPos][03],"@E 99,999.99") + "</n>" + Chr(13) + Chr(10)
  Next

  cTexto += "<n>" + Replicate("-", nMaxChar) + "</n>" + Chr(13) + Chr(10)
  cTexto += "<ce>" + "CONFIRA COM ATENCAO - EVITE TRANSTORNOS" + "</ce>" + Chr(13) + Chr(10)
  cTexto += "<n>" + Replicate("-", nMaxChar) + "</n>" + Chr(13) + Chr(10)

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
     cTexto += "<ce>" + "===>> TÍTULOS EM ABERTO <<===" + "</ce>" + Chr(13) + Chr(10)
     cTexto += "<n>" + Replicate("-", nMaxChar) + "</n>" + Chr(13) + Chr(10)
     cTexto += "<c>EMISSAO" + Space(5) + "Vencimento" + Space(3) + "TÍTULO" + Space(7) + "TP.COB." +;
               Space(4) + "VALOR" + "</c>" + Chr(13) + Chr(10)
     cTexto += "<n>" + Replicate("-", nMaxChar) + "</n>" + Chr(13) + Chr(10)

     While ! QSE1->(Eof())  
        cTexto += "<c>" + DToC(SToD(QSE1->E1_EMISSAO)) + Space(02) + DToC(SToD(QSE1->E1_VENCREA)) + Space(02) +;
                  AllTrim(QSE1->E1_PREFIXO) + "-" + AllTrim(QSE1->E1_NUM) + "/" + AllTrim(QSE1->E1_PARCELA) +;
                  Space(02) + IIf(AllTrim(QSE1->E1_TIPO) == "BOL","Boleto",IIf(AllTrim(QSE1->E1_TIPO) == "NF","N.Fiscal","")) +;
                  Space(02) + Transform(QSE1->E1_SALDO,"@E 99,999.99") + "</c>" + Chr(13) + Chr(10)
     
        nTtFin += QSE1->E1_SALDO

        QSE1->(dbSkip())
     EndDo

     cTexto += "<n>" + Replicate("-", nMaxChar) + "</n>" + Chr(13) + Chr(10)
     cTexto += "<n>" + Space(15) + "TOTAL EM ABERTO ===>>" + Space(03) + Transform(nTtFin,"@E 99,999.99") + "</n>" + Chr(13) + Chr(10)
  EndIf

  QSE1->(dbCloseArea()) 

  STWManagReportPrint(cTexto,1)

  FWRestArea(aArea)
Return

//--------------------------------------------------
/*/ Função PegImpos
  
    Pegar os impostos do Pedido.

  @author Anderson Almeida (TOTVS)
  @since   13/12/2024 - Desenvolvimento da Rotina.
/*/
//--------------------------------------------------
Static Function PegImpos(aRegSC6, nTtIPI, nTtICMSST, nTtFECST)
  Local nX := 0

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
  nTtFECST := 0

  For nX := 1 To Len(aRegSC6)
      nTtFECST += MaFisRet(nX,"IT_VFECPST")
  Next

  nTtIPI    := MaFisRet(,"NF_VALIPI")
  nTtICMSST := MaFisRet(,"NF_VALSOL") - nTtFECST

  MaFisEnd()
Return

//--------------------------------------------------
/*/ Função CriaPerg
  
    Criar perguntas para impressão.

  @author Anderson Almeida (TOTVS)
  @since   26/12/2024 - Desenvolvimento da Rotina.
/*/
//--------------------------------------------------
Static Function CriaPerg(cPerg)
  Local nX    := 0 
  Local nY    := 0
  Local aRegs := {}

  dbSelectArea("SX1")
  SX1->(dbSetOrder(1))

  aAdd(aRegs,{cPerg,"01","Pedido De  ?","","","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","","SC5"})
  aAdd(aRegs,{cPerg,"02","Pedido Até ?","","","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","","SC5"})

  For nX := 1 To Len(aRegs)
	    If ! SX1->(dbSeek(cPerg + aRegs[nX][02]))
		     RecLock("SX1",.T.)
		       For nY := 1 To FCount()
		           If nY <= Len(aRegs[nX])
			            FieldPut(nY, aRegs[nX][nY])
			         EndIf
		       Next
		     SX1->(MsUnlock())
	    EndIf
  Next
Return
