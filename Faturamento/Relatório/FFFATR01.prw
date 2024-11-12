#Include "TOTVS.ch"
#Include "PROTHEUS.ch"
#Include "TOPCONN.ch"

//---------------------------------------------------------
/*/ Rotina FFFATR01
  
    Impressão de Pedido de Venda em impressora não fiscal.

  @author Anderson Almeida (TOTVS)
  @since   21/10/2024 - Desenvolvimento da Rotina.
/*/
//----------------------------------------------------------
User Function FFFATR01()
  Local nPos      := 0
  Local nMaxChar  := 47           // Máximo de caracteres por linha
  Local nTotal    := 0
  Local nTtIPI    := 0
  Local nTtICMSST := 0
  Local nTtDesc   := 0
  Local nTtPedido := 0
  Local aMessage  := {}           // Mensagem longa
  Local aGrupo    := {}
  Local cStart    := GetSrvProfString("Startpath","")
  Local cLogo     := cStart + "Logo.bmp"
  Local cQry      := ""

  dbSelectArea("SA1")
  SA1->(dbSetOrder(1))
  SA1->(dbSeek(FWxFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI))

  INFImpBmp("<ibmp>" + cLogo + "</ibmp")

  INFTexto("<e><b>PD " + SC5->C5_NUM + "</b></e>")
  INFTexto("<ad>" + DToC(dDataBase) + Space(1) + Time() + "</ad>")

  INFTexto(SM0->M0_NOME)
  INFTexto(SC5->C5_CLIENTE + "/" + SC5->C5_LOJACLI + Space(5) + SC5->C5_XNOME)

  INFTexto("Fantasia " + AllTrim(SA1->A1_NREDUZ))

  INFTexto(AllTrim(SA1->A1_END))

  INFTexto("Fone " + SA1->A1_TEL)

  INFTexto("<l></l>")                    // Linha em branco

  INFTexto("Vend. " + Posicione("SA3",1,FWxFilial("SA3") + SC5->C5_VEND1,"A3_NOME"))

  INFTexto("Cond. Pagto " + Posicione("SE4",1,FWxFilial("SE4") + SC5->C5_CONDPAG,"E4_DESCRI"))

  INFTexto("It Descricao" + Space(15) + "Qtd  Unit  Desc  Total")

  INFTexto(Replicate("-", nMaxChar))     // Linha pontilhada
 
 // -- Impressão dos itens
 // ----------------------
  cQry := "Select SC9.C9_ITEM, SC9.C9_QTDLIB, SC9.C9_PRCVEN, SC9.C9_LOTECTL, SC6.C6_VALOR,"
  cQry += "       SC6.C6_VALDESC, SB1.B1_DESC, SB1.B1_GRUPO, SBM.BM_DESC"
  cQry += "  from " + RetSQLName("SC9") + " SC9, " + RetSQLName("SC6") + " SC6, " + RetSQLName("SB1") + " SB1"
  cQry += "   Left Join " + RetSQLName("SBM") + " SBM"
  cQry += "          on SBM.D_E_L_E_T_ <> '*'"
  cQry += "         and SBM.BM_FILIAL = '" + FWxFilial("SBM") + "'"
  cQry += "         and SBM.BM_GRUPO  = SB1.B1_GRUPO"
  cQry += "   where SC9.D_E_L_E_T_ <> '*'"
  cQry += "     and SC9.C9_FILIAL = '" + FWxFilial("SC9") + "'"
  cQry += "     and SC9.C9_PEDIDO = '" + SC5->C5_NUM + "'"
  cQry += "     and SC9.C9_BLEST  = ''"
  cQry += "     and SC6.D_E_L_E_T_ <> '*'"
  cQry += "     and SC6.C6_FILIAL = '" + FWxFilial("SC6") + "'"
  cQry += "     and SC6.C6_NUM    = SC9.C9_PEDIDO"
  cQry += "     and SC6.C6_ITEM   = SC9.C9_ITEM"
  cQry += "     and SB1.D_E_L_E_T_ <> '*'"
  cQry += "     and SB1.B1_FILIAL = '" + FwxFilial("SB1") + "'"
  cQry += "     and SB1.B1_COD    = SC9.C9_PRODUTO"
  cQry := ChangeQuery(cQry)
  dbUseArea(.T.,"TopConn",TCGenQry(,,cQry),"QSC9",.F.,.T.) 

  While ! QSC9->(Eof())
    If (nPos := aScan(aGrupo,{|x| x[01] == QSC9->B1_GRUPO})) == 0
       aAdd(aGrupo, {QSC9->B1_GRUPO,;    // 01 - Código do Grupo
                     QSC9->BM_DESC,;     // 02 - Descrição do Grupo
                     QSC9->C9_QTDLIB})   // 03 - Quantidade do produto
     else
       aGrupo[nPos][03] += QSC9->C9_QTDLIB
    EndIf

    INFTexto(QSC9->C9_ITEM + " " + Substr(QSC9_>B1_DESC,1,15) + Space(5) + AllTrim(Str(QSC9->C9_QTDLIB)) + Space(50) +;
             Transform(QSC9->C9_PRCVEN,"@E 99,999.99") + Space(2) +;
             Transform(QSC9->C6_VALDESC,"@E 99,999.99") + Space(2) +;
             Transform(QSC9->C6_VALOR,"@E 99,999.99"))

    INFTexto(IIf(Len(QSC9->B1_DESC) > 15,SubStr(QSC9->B1_DESC,16,30) + Space(16),Space(32)) +;
             "Lote:" + QSC9->C9_LOTECTL + Space(5))

    INFTexto("<l></l>")                    // Linha em branco

    QSC6->(dbSkip())
  EndDo

  QSC6->(dbCloseArea()) 
  
 // -- Impressão do Resumo (Grupos)
 // -------------------------------
 
  For nPos := 1 To Len(aGrupos)
  
  Next

    // MENSAGEM COM NO MÁXIMO 47 CARACTERES POR LINHA
    AAdd(aMessage, "Para efetuar trocas de mercadoria é necessário")
    AAdd(aMessage, "apresentar este cupom ou documento original de")
    AAdd(aMessage, "de venda. Produto: PRDT" + StrZero(Randomize(1, 999999), 6) + ".")
    AEval(aMessage, {|cMessage| INFTexto(cMessage)})

    // PRAZO DE TROCA
    INFTexto("Prazo máximo para a troca: " + DToC(dDatabase + 7) + ".")

    // LINHA EM BRANCO
    INFTexto("<l></l>")

    // CÓDIGO DE BARRAS
    INFCodeBar("<code128>", "(370)01250(240)405001353400(10)Z064(101)612688")

    // LINHA EM BRANCO
    INFTexto("<l></l>")

    // LINHA PONTILHADA
    INFTexto(Replicate("-", nMaxChar))

    // RODAPÉ
    INFTexto("LOJA: "     + StrZero(Randomize(1, 999), 3) + Space(1) +;
             "PDV: "      + StrZero(Randomize(1, 999), 3) + Space(nMaxChar - 31) +;
             "OPERADOR: " + StrZero(Randomize(1, 999), 3))

    // LINHA EM BRANCO
    INFTexto("<l></l>")

    // ACIONA A GUILHOTINA
    INFTexto("<gui></gui>")
Return (NIL)
