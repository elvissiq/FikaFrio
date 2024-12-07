#Include "TOTVS.ch"
#Include "PROTHEUS.ch"
#Include "TOPCONN.ch"
#INCLUDE "FWPRINTSETUP.CH"
#INCLUDE "RPTDEF.CH"

#DEFINE TAG_CENTER_INI	"<ce>"	//centralizado
#DEFINE TAG_CONDEN_INI	"<c>"	//condensado
#DEFINE TAG_CONDEN_FIM	"</c>"	//condensado
//Modalidades de TEF disponíveis no sistema
#DEFINE TEF_SEMCLIENT_DEDICADO  "2"         // Utiliza TEF Dedicado Troca de Arquivos                      
#DEFINE TEF_COMCLIENT_DEDICADO  "3"			// Utiliza TEF Dedicado com o Client
#DEFINE TEF_DISCADO             "4"			// Utiliza TEF Discado 
#DEFINE TEF_LOTE                "5"			// Utiliza TEF em Lote
#DEFINE TEF_CLISITEF			"6"			// Utiliza a DLL CLISITEF
#DEFINE TEF_CENTROPAG			"7"			// Utiliza a DLL tef mexico


// Possibilidades de uso do parametro MV_AUTOCOM
#DEFINE DLL_SIGALOJA			0			// Usa somente periféricos da SIGALOJA.DLL
#DEFINE DLL_SIGALOJA_AUTOCOM	1			// Usa periféricos da SIGALOJA.DLL e da AUTOCOM
#DEFINE DLL_AUTOCOM				2			// Usa somente periféricos da AUTOCOM

// Retornos da GetRemoteType()
#DEFINE REMOTE_JOB	 			-1			// Não há Remote, executando Job
#DEFINE REMOTE_DELPHI			0			// O Remote está em Windows Delphi
#DEFINE REMOTE_QT				1			// O Remote está em Windows QT
#DEFINE REMOTE_LINUX			2			// O Remote está em Linux
#DEFINE REMOTE_HTML				5			// Não há Remote, executando HTML

// Tipos de equipamentos
#DEFINE EQUIP_IMPFISCAL			1
#DEFINE EQUIP_PINPAD			2
#DEFINE EQUIP_CMC7				3
#DEFINE EQUIP_GAVETA			4
#DEFINE EQUIP_IMPCUPOM			5
#DEFINE EQUIP_LEITOR			6
#DEFINE EQUIP_BALANCA			7
#DEFINE EQUIP_DISPLAY			8
#DEFINE EQUIP_IMPCHEQUE			9
#DEFINE EQUIP_IMPNAOFISCAL		10			

// Qual DLL o Equipamento esta utilizando
#DEFINE EQUIP_DLL_NENHUM		0			// O equipamento nao foi configurado 
#DEFINE EQUIP_DLL_AUTOCOM		1			// O equipamento foi configurado para utilizar a AUTOCOM
#DEFINE EQUIP_DLL_SIGALOJA		2			// O equipamento foi configurado para utilizar a SIGALOJA

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
  Local cTexto := ""
  Local cTxImp := ""
  Local lCondensa := .T.
  Local cCRLF 	:= Chr(13) + Chr(10)
Local cTagCondIni	:= Iif(lCondensa, TAG_CONDEN_INI , "")
Local cTagCondFim	:= IIf(lCondensa, TAG_CONDEN_FIM , "")
	Local		cImpressora	:= LJGetStation("IMPFISC")
	Local		cPorta := "AUTO"
  	Private nMaxChar 		:= 47 // MÁXIMO DE CARACTERES POR LINHA

  dbSelectArea("SA1")
  SA1->(dbSetOrder(1))
  SA1->(dbSeek(FWxFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI))

  //nHandle := IFAbrir( cImpressora, c$orta )
// Inicia a comunicação com a impressora %iscal.
// Parâmetros:cImpressora – nome da impressora retornada pela função I%(I)!ARcPorta – *ual a porta ser+ utili"ada para comunicação. Pe'.: C,-?/ C,-0. Retorno:nHandle – Handle da Impressora 1ue dever+ ser informado em todas as outras funç2espara comunicação com a mesma

Alert("Impressora: " + cImpressora)
				STImPFNfce( @{"C",cImpressora,nHdlECF})
	
 // 				FwLogMsg("INFO",,"INTEGRATION",FunName(),"","01","Aguarde. Abrindo a Impressora...",0,(nStart - Seconds()),{})
	//				nHdlECF := INFAbrir( cImpressora,cPorta )

	cTexto := cTexto + '<ce>' + 'Prezado(a) Cliente gostaríamos de informar ' + '</ce>' + Chr(13) + Chr(10)
	cTexto := cTexto + '<ce>' + 'que o prazo para devolução é de 30 dias ' + '</ce>' + Chr(13) + Chr(10)
	cTexto := cTexto + '<ce>' + 'a partir da data de recebimento do produto. ' + '</ce>' + Chr(13) + Chr(10)
	cTexto := cTexto + ' ' + Chr(13) + Chr(10)
	cTexto := cTexto + '<ce>' + 'Agradecemos pela sua atenção! ' + '</ce>' + Chr(13) + Chr(10)

	cTexto := cTexto + Replicate("-", nMaxChar)						     + Chr(13) + Chr(10)

	cTxImp := StrTran( cTexto, ',', '.' )
	STWManagReportPrint(cTxImp,1) //Envia comando para a Impressora
  /*
			cTexto += TAG_CENTER_INI
			cTexto += cTagCondIni
			cTexto += SC5->C5_NUM
			cTexto += cTagCondFim
			cTexto += cCRLF

STWPrintTextNotFiscal(cTexto)

//  INFImpBmp("<ibmp>" + cLogo + "</ibmp")

  INFTexto("<e><b>PD " + SC5->C5_NUM + "</b></e>")
  INFTexto("<ad>" + DToC(dDataBase) + Space(1) + Time() + "</ad>")

//  INFTexto(SM0->M0_NOME)
// INFTexto(SC5->C5_CLIENTE + "/" + SC5->C5_LOJACLI + Space(5) + SC5->C5_XNOME)

  INFTexto("<n>Fantasia " + AllTrim(SA1->A1_NREDUZ) + "</n>")
/*
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

    INFTexto(QSC9->C9_ITEM + " " + Substr(QSC9->B1_DESC,1,15) + Space(5) + AllTrim(Str(QSC9->C9_QTDLIB)) + Space(50) +;
             Transform(QSC9->C9_PRCVEN,"@E 99,999.99") + Space(2) +;
             Transform(QSC9->C6_VALDESC,"@E 99,999.99") + Space(2) +;
             Transform(QSC9->C6_VALOR,"@E 99,999.99"))

    INFTexto(IIf(Len(QSC9->B1_DESC) > 15,SubStr(QSC9->B1_DESC,16,30) + Space(16),Space(32)) +;
             "Lote:" + QSC9->C9_LOTECTL + Space(5))

    INFTexto("<l></l>")                    // Linha em branco

    QSC9->(dbSkip())
  EndDo

  QSC9->(dbCloseArea()) 
  
 // -- Impressão do Resumo (Grupos)
 // -------------------------------
  INFTexto("RESUMO: ")

  For nPos := 1 To Len(aGrupo)
      INFTexto(aGrupo[nPos][01] + Space(2) + aGrupo[nPos][02] + Space(2) +;
               Transform(aGrupo[nPos][03],"@E 99,999.99"))
  Next

    // MENSAGEM COM NO MÁXIMO 47 CARACTERES POR LINHA
/*    AAdd(aMessage, "Para efetuar trocas de mercadoria é necessário")
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
*/
    // LINHA PONTILHADA
    INFTexto("<n>" + Replicate("-", nMaxChar) + "</n>")

    // RODAPÉ
//    INFTexto("LOJA: "     + StrZero(Randomize(1, 999), 3) + Space(1) +;
 //            "PDV: "      + StrZero(Randomize(1, 999), 3) + Space(nMaxChar - 31) +;
 //            "OPERADOR: " + StrZero(Randomize(1, 999), 3))

    // LINHA EM BRANCO
    INFTexto("<l></l>")

    // ACIONA A GUILHOTINA
    INFTexto("<gui></gui>")
Return (NIL)
