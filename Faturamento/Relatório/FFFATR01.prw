#Include "TOTVS.ch"
#Include "PROTHEUS.ch"
#Include "TOPCONN.ch"
#Include "FWPRINTSETUP.CH"
#Include "RPTDEF.CH"
#Include "FWADAPTEREAI.CH"
#Include "TBICONN.ch"

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
  Local nX        := 0
  Local nY        := 0
  Local nPos      := 0
  Local nTtIPI    := 0
  Local nTtICMSST := 0
  Local nTtFECST  := 0
  Local nTtPedido := 0
  Local nTtFin    := 0
  Local aGrupo    := {}
  Local aCliente  := {}
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
  cQry := "Select SC9.C9_PEDIDO, SC9.C9_CLIENTE, SC9.C9_LOJA, SC9.C9_ITEM, SC9.C9_PRODUTO, SC9.C9_QTDLIB, SC9.C9_PRCVEN,"
  cQry += "       SC9.C9_LOTECTL, SC5.C5_CONDPAG, SC5.C5_EMISSAO, SC5.C5_COMENT, SC5.C5_TIPO, SC5.C5_TIPOCLI,"
  cQry += "       SA1.A1_NOME, SA1.A1_NREDUZ, SA1.A1_XROTA, SA1.A1_END, SA1.A1_XNUMEND, SA1.A1_COMPLEM, SA1.A1_BAIRRO, SA1.A1_MUN,"
  cQry += "       SA1.A1_TEL, SA3.A3_NOME, SE4.E4_DESCRI, SC6.C6_TES, SC6.C6_NFORI, SC6.C6_SERIORI, SC6.C6_VALOR,"
  cQry += "       SC6.C6_VALDESC, SB1.B1_DESC, SB1.B1_GRUPO, SBM.BM_DESC, Z02.Z02_DESCRI"
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
  cQry += "     and SC9.C9_BLEST  = ''"
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
MemoWrite("C:\temp\TESTE.txt",cQry)
  If QSC9->(Eof())
     ApMsgInfo("Pedido Bloqueado ou Encerrado.")

     QSC9->(dbCloseArea())

     FWRestArea(aArea)

     Return
  EndIf 

  While ! QSC9->(Eof())
    If (nPos := aScan(aGrupo,{|x| x[01] == QSC9->B1_GRUPO .and. x[04] == QSC9->C9_PEDIDO})) == 0
       aAdd(aGrupo, {QSC9->B1_GRUPO,;    // 01 - Código do Grupo
                     QSC9->BM_DESC,;     // 02 - Descrição do Grupo
                     QSC9->C9_QTDLIB,;   // 03 - Quantidade do produto
                     QSC9->C9_PEDIDO})   // 04 - Pedido
     else
       aGrupo[nPos][03] += QSC9->C9_QTDLIB
    EndIf

    If (nPos := aScan(aCabPed,{|x| x[01] == QSC9->C9_PEDIDO})) == 0
       aAdd(aCabPed, {QSC9->C9_PEDIDO,;                  // 01 - Pedido
                      AllTrim(QSC9->C9_CLIENTE),;        // 02 - Código do Cliente
                      AllTrim(QSC9->C9_LOJA),;           // 03 - Loja do Cliente
                      AllTrim(QSC9->A1_NOME),;           // 04 - Nome do Cliente
                      AllTrim(QSC9->A1_NREDUZ),;         // 05 - Nome de fantasia
                      QSC9->A1_XROTA,;                   // 06 - Código da Rota
                      AllTrim(QSC9->Z02_DESCRI),;        // 07 - Descrição da Rota
                      AllTrim(QSC9->A1_END),;            // 08 - Endereço do cliente
                      AllTrim(QSC9->A1_COMPLEM),;        // 09 - Complemento do endereço
                      AllTrim(QSC9->A1_BAIRRO),;         // 10 - Bairro
                      AllTrim(QSC9->A1_MUN),;            // 11 - Municipio
                      QSC9->A1_TEL,;                     // 12 - Telefone
                      AllTrim(QSC9->A3_NOME),;           // 13 - Nome do vendedor
                      QSC9->C5_CONDPAG,;                 // 14 - Condição de pagamento
                      AllTrim(QSC9->E4_DESCRI),;         // 15 - Descrição condição de pagamento
                      SToD(QSC9->C5_EMISSAO),;           // 16 - Emissão do Pedido
                      AllTrim(QSC9->C5_COMENT),;         // 17 - Observação do Pedido
                      0,;                                // 18 - Total do Pedido
                      0,;                                // 19 - Total do Desconto
                      QSC9->C5_TIPO,;                    // 20 - C:Cliente , F:Fornecedor
                      QSC9->C5_TIPOCLI,;                 // 21 - Tipo do Cliente/Fornecedor
                      AllTrim(QSC9->A1_XNUMEND)})        // 20 - Número do endereço

       nPos := Len(aCabPed) 
    EndIf

    aAdd(aItePed, {QSC9->C9_PEDIDO,;        // 01 - Pedido
                   QSC9->C9_ITEM,;          // 02 - Item
                   AllTrim(QSC9->B1_DESC),; // 03 - Descrição do Produto
                   QSC9->C9_QTDLIB,;        // 04 - Quantidade do Produto
                   QSC9->C9_PRCVEN,;        // 05 - Preço de venda
                   QSC9->C6_VALDESC,;       // 06 - Valor do desconto
                   QSC9->C6_VALOR,;         // 07 - Valor total do item
                   QSC9->C9_LOTECTL,;       // 08 - Número do lote 
                   QSC9->C9_PRODUTO,;       // 09 - Produto
                   QSC9->C6_TES,;           // 10 - TES
                   QSC9->C6_NFORI,;         // 11 - Nota Fiscal origem
                   QSC9->C6_SERIORI,;       // 12 - Serie da Nota Fiscal de origem
                   QSC9->C6_VALOR})         // 13 - Valor total do item  

    aCabPed[nPos][18] += QSC9->C6_VALOR
    aCabPed[nPos][19] += QSC9->C6_VALDESC

    QSC9->(dbSkip())
  EndDo

  QSC9->(dbCloseArea()) 

  nHdlECF := INFAbrir(cImpressora,cPorta)

  If nHdlECF == -1
	   APMsgAlert("NFC-e: Não foi possível estabelecer comunicação com a Impressora:" + cImpressora, "ATENÇÃO")

	   Return
  EndIf

  For nX := 1 To Len(aCabPed)
      cTexto    := ""
      nTtIPI    := 0
      nTtICMSST := 0
      nTtFECST  := 0
      nTtFin    := 0
      aCliente  := {}
      aRegSC6   := {}
  
      aAdd(aCliente, aCabPed[nX][02])             // 01 - Codigo Cliente/Fornecedor
      aAdd(aCliente, acabPed[nX][03])             // 02 - Loja do Cliente/Fornecedor
      aAdd(aCliente, aCabPed[nX][20])             // 03 - C:Cliente , F:Fornecedor
      aAdd(aCliente, aCabPed[nX][21])             // 04 - Tipo do Cliente/Fornecedor

      For nY := 1 To Len(aItePed)
          If aCabPed[nX][01] == aItePed[nY][01]
             aAdd(aRegSC6,{aItePed[nY][09],;        // 01 - Produto
                           aItePed[nY][10],;        // 02 - TES
                           aItePed[nY][04],;        // 03 - Quantidade liberada
                           aItePed[nY][05],;        // 04 - Preço de venda
                           aItePed[nY][06],;        // 05 - Valor de desconto
                           aItePed[nY][11],;        // 06 - Nota Fiscal origem
                           aItePed[nY][12],;        // 07 - Serie da Nota Fiscal de origem
                           aItePed[nY][13]})        // 08 - Valor total do item
          EndIf
      Next   
      
      PegImpos(@aCliente, @aRegSC6, @nTtIPI, @nTtICMSST, @nTtFECST)        // Pegar os impostos

      nTtPedido := (aCabPed[nX][18] + nTtIPI + nTtICMSST + nTtFECST) - aCabPed[nX][19]

      aParcelas := Condicao(nTtPedido,aCabPed[nX][14],,aCabPed[nX][16])    // Pegar as parcelas
  
      If cModImp == "B"
         INFImpBmp(cPathRmt,"lgmid01.bmp")
         cTexto := ""

       elseIf cModImp == "E"
              cTexto := "<ibmp>" + cPathRmt + "lgmid01.bmp" + "</ibmp>"
      EndIf

      cTexto += "<b>PV " + aCabPed[nX][01] + "</b>" + Space(20) + "<n>" + DToC(dDataBase) + " " + Time() + "</n>" + Chr(13) + Chr(10)
      cTexto += "<n>" + IIf(! Empty(aCabPed[nX][06]), SubStr(aCabPed[nX][07],1,25), Space(25)) +;
                "  " + aCabPed[nX][10] + "</n>" + Chr(13) + Chr(10)
      cTexto += "<n>" + aCabPed[nX][11] + "</n>" + Chr(13) + Chr(10)
      cTexto += "<n>" + aCabPed[nX][02] + "/" + aCabPed[nX][03] + " " + SubStr(aCabPed[nX][04],1,34) + "</n>" + Chr(13) + Chr(10)
      cTexto += "<n>Fantasia " + aCabPed[nX][05] + "</n>" + Chr(13) + Chr(10)
      cTexto += "<n>" + aCabPed[nX][08] + IIf(Empty(aCabPed[nX][20]),"",", " + aCabPed[nX][20]) + "</n>" + Chr(13) + Chr(10)
      cTexto += "<n>Fone " + Transform(aCabPed[nX][12],"@R 9999-9999") + "</n>" + Chr(13) + Chr(10)
      cTexto += "<n>P. Ref. " + aCabPed[nX][09] + "</n>" + Chr(13) + Chr(10)
      cTexto += "<n>Vend. " + aCabPed[nX][13] + "</n>" + Chr(13) + Chr(10)
      cTexto += "<n>Vencto " + DToC(aParcelas[01][01]) + " "
      cTexto += "Cond. Pagto " + aCabPed[nX][15] + "</n>" + Chr(13) + Chr(10)
      cTexto += "<c>It  Descricao" + Space(21) + "Qtde    Unit     Desc    Total</c>" + Chr(13) + Chr(10)
      cTexto += "<n>" + Replicate("-", nMaxChar) + "</n>" + Chr(13) + Chr(10)

      For nY := 1 To Len(aItePed)
          If aCabPed[nX][01] == aItePed[nY][01]
             cTexto += "<c>" + aItePed[nY][02] + " " + PadR(Substr(aItePed[nY][03],1,28),30)
             cTexto += " " + AllTrim(Str(aItePed[nY][04]))
             cTexto += " " + Transform(aItePed[nY][05],"@E 99,999.99")
             cTexto += " " + Transform(aItePed[nY][06],"@E 9,999.99")
             cTexto += " " + Transform(aItePed[nY][07],"@E 99,999.99")
             cTexto += "</c>" + Chr(13) + Chr(10)

             cDesc := Substr(aItePed[nY][03],29,30)
    
             cTexto += "<c>" + IIf(! Empty(cDesc),cDesc + Space(02),"") + "Lote:" + aItePed[nY][08] + "</c>" + Chr(13) + Chr(10)
          EndIf
      Next

      cTexto += "<n>" + Replicate("-", nMaxChar) + "</n>" + Chr(13) + Chr(10)
      cTexto += "<n>" + Space(18) + PadR("VALOR TABELA",20) + Transform(aCabPed[nX][18],"@E 99,999.99") + "</n>" + Chr(13) + Chr(10)
      cTexto += "<n>" + Space(18) + PadR("DESCONTO",20) + Transform(aCabPed[nX][19],"@E 99,999.99") + "</n>" + Chr(13) + Chr(10)
      cTexto += "<n>" + Space(18) + PadR("IPI",20) + Transform(nTtIPI,"@E 99,999.99") + "</n>" + Chr(13) + Chr(10)
      cTexto += "<n>" + Space(18) + PadR("ICMS SUBST TRIB",20) + Transform(nTtICMSST,"@E 99,999.99") + "</n>" + Chr(13) + Chr(10)
      cTexto += "<n>" + Space(18) + PadR("TOTAL DO PEDIDO",20) + Transform(nTtPedido,"@E 99,999.99") + "</n>" + Chr(13) + Chr(10)
      cTexto += "<n>" + "OBS.: " + "</n>" + Chr(13) + Chr(10)

      If ! Empty(aCabPed[nX][17])
         cTexto += "<n>" + PadR(Substr(aCabPed[nX][17],1,50),50) + "</n>" + Chr(13) + Chr(10)
     
         If ! Empty(SubStr(aCabPed[nX][17],51,50))
            cTexto += "<n>" + PadR(Substr(aCabPed[nX][17],51,50),50) + "</n>" + Chr(13) + Chr(10)
         EndIf
  
         If ! Empty(SubStr(aCabPed[nX][17],101,50))
            cTexto += "<n>" + PadR(Substr(aCabPed[nX][17],101,50),50) + "</n>" + Chr(13) + Chr(10)
         EndIf
      EndIf   

      cTexto += "<l></l>" + Chr(13) + Chr(10)

     // -- Impressão do Resumo (Grupos)
     // -------------------------------
      cTexto += "<ce>" + "RESUMO:" + "</ce>" + Chr(13) + Chr(10)

      For nPos := 1 To Len(aGrupo)
          If aCabPed[nX][01] == aGrupo[nPos][04] 
             cTexto += "<n>" + Space(3) + PadR(aGrupo[nPos][02],30) + Space(3) +;
                       Transform(aGrupo[nPos][03],"@E 99,999.99") + "</n>" + Chr(13) + Chr(10)
          EndIf
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
      cQry += "     and SE1.E1_CLIENTE = '" + aCabPed[nX][02] + "'"
      cQry += "     and SE1.E1_LOJA    = '" + aCabPed[nX][03] + "'"
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
  Next

  FWRestArea(aArea)
Return

//--------------------------------------------------
/*/ Função PegImpos
  
    Pegar os impostos do Pedido.

  @author Anderson Almeida (TOTVS)
  @since   13/12/2024 - Desenvolvimento da Rotina.
/*/
//--------------------------------------------------
Static Function PegImpos(aCliente, aRegSC6, nTtIPI, nTtICMSST, nTtFECST)
  Local nX := 0

  dbSelectArea("SB1")
  SB1->(dbSetOrder(1))
     
  MaFisIni(aCliente[01],;                           // 01 - Codigo Cliente/Fornecedor
           aCliente[02],;                           // 02 - Loja do Cliente/Fornecedor
           IIf(aCliente[03] $ "D;B", "F", "C"),;    // 03 - C:Cliente , F:Fornecedor
           aCliente[03],;                           // 04 - Tipo da NF
           aCliente[04],;                           // 05 - Tipo do Cliente/Fornecedor
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

  cPerg := PadR(cPerg,10)

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
