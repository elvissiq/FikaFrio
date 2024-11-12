#Include "PROTHEUS.ch"
#Include "TOTVS.ch"

// --------------------------------------------------------------------- 
/*/ Rotina MATA410
  Ponto de entrada M410VRES
    
   É executado após a confirmação da eliminação de residuos no pedido
   de venda e antes do inicio da transação do mesmo.

   Implementado para:
      - Enviar Pedido de Venda para o FUSION.

  @author Anderson Almeida - TOTVS
  @since   28/08/2024 
/*/
// --------------------------------------------------------------------- 
User Function M410VRES()
  Local lRet      := .T.
  Local aArea     := GetArea()
  Local oFusion   := PCLSFUSION():New()
  Local aRet      := {}
  Local nQtde     := 0
  Local nPeso     := 0
  Local nCubagem  := 0
  Local nTtVend   := 0
  Local cDsRegiao := ""
  Local cQry      := ""
  Local cUltSeq   := ""

  If SC5->C5_TPCARGA == "1"
    // -- Pegar último sequêncial do FUSION
    // ------------------------------------
     cQry := "Select Max(SC9.C9_XSEQFUS) as ULTSEQ from " + RetSqlName("SC9") + " SC9"
     cQry += "  where SC9.D_E_L_E_T_ <> '*'"
     cQry += "    and SC9.C9_FILIAL  = '" + FWxFilial("SC9") + "'"
     cQry += "    and SC9.C9_PEDIDO  = '" + SC5->C5_NUM + "'"
     cQry := ChangeQuery(cQry)
     dbUseArea(.T.,"TopConn",TCGenQry(,,cQry),"QSC9",.F.,.T.) 

     If ! QSC9->(Eof())
        cUltSeq := QSC9->ULTSEQ
     EndIf

     QSC9->(dbCloseArea())
    // ------------------------------------

     oFusion:aRegistro := {}

     cDsRegiao := AllTrim(Posicione("SX5",1,FWxFilial("SX5") + "A2" + SC5->C5_XREGIAO,"X5_DESCRI"))

     dbSelectArea("SC6")
     SC6->(dbSetOrder(1))
     SC6->(dbSeek(FWxFilial("SC6") + SC5->C5_NUM))

     While ! SC6->(Eof()) .and. SC6->C6_FILIAL == FWxFilial("SC6") .and. SC6->C6_NUM == SC5->C5_NUM 
        dbSelectArea("SB1")
        SB1->(dbSetOrder(1))
        SB1->(dbSeek(FWxFilial("SB1") + SC6->C6_PRODUTO))

        dbSelectArea("SB5")
        SB5->(dbSetOrder(1))
        SB5->(dbSeek(FWxFilial("SB5") + SC6->C6_PRODUTO))

        nQtde := SC6->C6_QTDVEN - SC6->C6_QTDENT

        aAdd(oFusion:aRegistro, {SC6->C6_PRODUTO,;                   // 01 - Produto
                                 SB1->B1_DESC,;                      // 02 - Descrição
                                 SB1->B1_UM,;                        // 03 - Unidade do Produto 
                                 SC6->C6_QTDVEN,;                    // 04 - Quantidade liberada
                                 (SC6->C6_QTDVEN * SB1->B1_PESO),;   // 05 - Peso
                                 SC6->C6_PRCVEN,;                    // 06 - Valor unitário
                                 (SC6->C6_QTDVEN * SC6->C6_PRCVEN),; // 07 - Total
                                 0,;                                 // 08 - Valor ICMS ST
                                 SB1->B1_POSIPI,;                    // 09 - NCM
                                 0,;                                 // 10 - CST
                                 SC5->C5_MENNOTA,;                   // 11 - Observação
                                 0,;                                 // 12 - Peso total
                                 0,;                                 // 13 - Cubagem total
                                 0,;                                 // 14 - Total da Venda
                                 SC5->C5_NUM,;                       // 15 - Número do Pedido
                                 SC5->C5_CLIENTE,;                   // 16 - Código do Cliente
                                 SC5->C5_LOJACLI,;                   // 17 - Loja do Cliente
                                 SC5->C5_VEND1,;                     // 18 - Código do Vendedor
                                 SC5->C5_EMISSAO,;                   // 19 - Data da emissão do pedido
                                 IIf(Empty(cUltSeq),0,Val(cUltSeq)),;// 20 - Sequencial da FUSION
                                 "",;                                // 21 - Número da Carga
                                 SC5->C5_XREGIAO,;                   // 22 - Código da Região
                                 cDsRegiao,;                         // 23 - Descrição da Região
                                 0,;                                 // 24 - Número do registro
                                 "L"})                               // 25 - Status do item (L-Liberado/B-Bloqueado)
  
        nPeso    += SC6->C6_QTDVEN * SB1->B1_PESO
        nCubagem += SC6->C6_QTDVEN * (SB5->B5_COMPR * SB5->B5_ALTURA * SB5->B5_LARG)
        nTtVend  += SC6->C6_PRCVEN * SC6->C6_QTDVEN

        SC6->(dbSkip())
     EndDo

     oFusion:aRegistro[01][12] := nPeso
     oFusion:aRegistro[01][13] := nCubagem
     oFusion:aRegistro[01][14] := nTtVend

    // -- Parâmetro: 1 - Normal, B - Bloqueado ou 9 - Cancelar;
    // --            S = Pode formar carga;
    // --           .T. = N. Carga 
    // -------------------------------------------------------- 
     oFusion:saveEntregaServico("9","N",.F.)
           
     aRet := oFusion:Enviar("saveEntregaServico")     // Enviar para FUSION

     If aRet[01]
        ApMsgInfo("Pedido enviado para FUSION com sucesso.")
      else
        ApMsgAlert(aRet[02],"ATENÇÃO") 

        lRet := .F. 
     EndIf
  EndIf

  RestArea(aArea)
Return lRet
