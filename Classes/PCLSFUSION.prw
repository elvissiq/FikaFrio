#Include "PROTHEUS.ch"
#Include "TOTVS.ch"
#Include "TOPCONN.ch"
#Include "TBICONN.ch"

// ----------------------------------------------
/*/ Classe ACLSFUSION

    Classe para integrção do FUSION x PROTHEUS.

  @author Anderson Almeida - TOTVS
  @since   26/08/2024 - Desenvolvimento da Rotina.
/*/
// -----------------------------------------------
Class PCLSFUSION
  Data lRetorno   as Boolean
  Data aRegistro  as Array
  Data cLogin     as string
  Data cPassword  as String
  Data cFilFus    as String
  Data cBody      as String
  Data oParseJSON

 // --- Definição dos métodos
 // -------------------------
  Method New() Constructor
  Method sendClientes(pCliente,pLoja)                      // Montar requisição Cadastro de Cliente
  Method sendVeiculos(pCodigo)                             // Montar requisição Cadastro de Veí­culo
  Method sendMotoristas(pCodigo)                           // Montar requisição Cadastro de Motorista
  Method sendAjudantes(pCodigo)                            // Montar requisição Cadastro de Ajudante
  Method LerPedidoVenda(pPedido,pSeq,pVldSC5,pExcluido)    // Verificar se o pedido de venda está valido para envio e montar
  Method saveEntregaServico(pStatus,pForma,lCarga)         // Montar de Pedido de Venda para envio
  Method detalheCarga(pCarga,pDtInicio,pDtFim)             // Montar requisição do Detalhe da Carga
  Method getIntErpFilial()                                 // Montar requisição para importação de Carga 
  Method setIntErp(pIntId,pCarga)                          // Informar ao FUSION a gravação da carga
  Method AltCarga(pForma,pPedido,pRecno)                   // Montar requisição e enviar para FUSION 
  Method atualizaCarga(pJsonData)                          // Monta requisição para atualizar dados da carga
  Method Enviar(pMetodo,pSchedule)                         // Enviar para o FUSION
EndClass

//-------------------------------------------------------------------
/*/{protheusDoc.marcadores_ocultos} PCLSFUSION()
  Definição do construtor da classe

  @author Anderson Almeida (TOTVS NE)
  @version P12.1.17
  @since 24/03/2021	
/*/
//-------------------------------------------------------------------
Method New() Class PCLSFUSION
  self:cLogin     := SuperGetMv("FF_XFUSUSE",.F.,"")
  self:cPassword  := SuperGetMv("FF_XFUSPWD",.F.,"")
  self:cBody      := ""
  self:aRegistro  := {}
  self:oParseJSON := Nil
Return Self

//-------------------------------------------------------------------
/*/{protheusDoc.marcadores_ocultos} PCLSFUSION
  Objeto sendClientes
  
    Montagem do Cadastro de Cliente

  @author Anderson Almeida (TOTVS NE)
  @version P12.1.17
  @since 31/03/2021	
/*/
//-------------------------------------------------------------------
Method sendClientes(pCliente,pLoja) Class PCLSFUSION
  Local nPrxId  := 0
  Local cA1Cod  := pCliente
  Local cA1Loja := pLoja
  Local cQuery  := ""

 // --- Pegar o próximo Id do FUSION
 // --------------------------------
  dbSelectArea("SA1")
  SA1->(dbSetOrder(1))
  SA1->(dbSeek(FWxFilial("SA1") + cA1Cod + cA1Loja))

  If SA1->A1_XIDFUS == 0
     cQuery := "Select (Max(A1_XIDFUS) + 1) as ID from " + RetSqlName("SA1")
     cQuery += "  where D_E_L_E_T_ <> '*'"
     cQuery += "    and A1_FILIAL  = '" + FWxFilial("SA1") + "'"
     cQuery := ChangeQuery(cQuery)
     dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"QSA1",.F.,.T.)

     nPrxId := IIf(QSA1->ID == 0,1,QSA1->ID)

     QSA1->(dbCloseArea())
    
     Reclock("SA1",.F.)
       Replace SA1->A1_XIDFUS with nPrxId
     SA1->(MsUnlock())
   else
     nPrxId := SA1->A1_XIDFUS
  EndIf     
 // --------------------------------

  self:cBody := '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
  self:cBody += ' xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"'
  self:cBody += ' xmlns:urn="urn:myInputNamespace">'
  self:cBody += ' <soapenv:Header/>'
  self:cBody += ' <soapenv:Body>'
  self:cBody += '   <urn:sendClientes soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'
  self:cBody += '     <login xsi:type="xsd:string">' + self:cLogin + '</login>'
  self:cBody += '     <senha xsi:type="xsd:string">' + self:cPassword + '</senha>'
  self:cBody += '     <array_dados><![CDATA['
  self:cBody += '       ['  
  self:cBody += '         {'
  self:cBody += '          "campo_alt":"NEW_59",'
  self:cBody += '          "seq_id":"' + AllTrim(Str(nPrxId)) + '",'
  self:cBody += '          "codigo_cliente":"' + AllTrim(SA1->A1_COD) + AllTrim(SA1->A1_LOJA) + '",'
  self:cBody += '          "filial_padrao":"1",'
  self:cBody += '          "descr_cliente":"' + FwNoAccent(AllTrim(SA1->A1_NREDUZ)) + '",'
  self:cBody += '          "razao_cliente":"' + FwNoAccent(AllTrim(SA1->A1_NOME)) + '",'
  self:cBody += '          "cnpj_cpf_cliente":"' + SA1->A1_CGC + '",'
  self:cBody += '          "cliente_cod_rota_erp":"",'
  self:cBody += '          "cliente_descricao_rota ":"",'
  self:cBody += '          "cod_segmento":"2",'
  self:cBody += '          "descr_segmento":"' + AllTrim(Posicione("SX5",1,FWxFilial("SX5") + "T3" + SA1->A1_SATIV1,"X5_DESCRI")) + '",'
  self:cBody += '          "cep_cliente":"' + IIF(!Empty(SA1->A1_CEPE),SA1->A1_CEPE,SA1->A1_CEP) + '",'
  self:cBody += '          "end_cliente":"' + FwNoAccent(Alltrim(IIF(!Empty(SA1->A1_ENDENT),SA1->A1_ENDENT,SA1->A1_END))) + '",'
  self:cBody += '          "num_end_cliente":"' + AllTrim(SA1->A1_XNUMEND) + '",'
  self:cBody += '          "bairro_cliente":"' + FwNoAccent(Alltrim(IIF(!Empty(SA1->A1_BAIRROE),SA1->A1_BAIRROE,SA1->A1_BAIRRO))) + '",'
  self:cBody += '          "cidade_cliente":"' + FwNoAccent(Alltrim(IIF(!Empty(SA1->A1_MUNE),SA1->A1_MUNE,SA1->A1_MUN))) + '",'
  self:cBody += '          "uf_cliente":"' + IIF(!Empty(SA1->A1_ESTE),SA1->A1_ESTE,SA1->A1_EST) + '",'
  self:cBody += '          "email1_cliente":"' + FwNoAccent(AllTrim(SA1->A1_EMAIL)) + '",'
  self:cBody += '          "email2_cliente":"",'
  self:cBody += '          "email3_cliente":"",'
  self:cBody += '          "tel1_cliente":"' + AllTrim(SA1->A1_DDD) + '-' + Substr(SA1->A1_TEL,1,4) +;
                                          Substr(SA1->A1_TEL,5,4) + '",'
  self:cBody += '          "tel2_cliente" :"",'
  self:cBody += '          "tel3_cliente" :"",'
  self:cBody += '          "data_cadastro_cliente":"' + AllTrim(Substr(DToS(dDatabase),1,4) + '-' + Substr(DToS(dDatabase),5,2);
                                                                + '-' + Substr(DToS(dDataBase),7,2) + ' ' + Time()) + '",'
  self:cBody += '          "vlr_credito_cliente":"0",'
  self:cBody += '          "saldo_disp_cliente":"0",'
  self:cBody += '          "vlr_tits_vencido_cliente":"0",'
  self:cBody += '          "vlr_tits_vencer_cliente":"0",'
  self:cBody += '          "status_cred_cliente":"Liberado",'
  self:cBody += '          "data_ult_compra":"' + AllTrim(Substr(DToS(SA1->A1_ULTCOM),1,4) + '-' + Substr(DToS(SA1->A1_ULTCOM),5,2);
                                                          + '-' + Substr(DToS(SA1->A1_ULTCOM),7,2) + ' ' + Time()) + '",'
  self:cBody += '          "forma_pgto_cliente":"1",'
  self:cBody += '          "turnos_entrega":"08:00-12:00;14:00-17:00",'
  self:cBody += '          "prioritario":"N",'
  self:cBody += '          "bloqueiosefaz":"N",'
  self:cBody += '          "rede_loja_cliente":"' + SA1->A1_LOJA + '",'
  self:cBody += '          "end_alt" :
  self:cBody += '             [{ }]'
  self:cBody += '        }'
  self:cBody += '       ]'
  self:cBody += '      ]]>'
  self:cBody += '     </array_dados>'
  self:cBody += '   </urn:sendClientes>'
  self:cBody += ' </soapenv:Body>'
  self:cBody += '</soapenv:Envelope>'

  MemoWrite("C:\Temp\Cliente.xml",self:cBody)

Return .T.

//-------------------------------------------------------------------
/*/{protheusDoc.marcadores_ocultos} PCLSFUSION
  Objeto sendVeiculos
  
    Montagem do Cadastro de Veí­culo

  @author Anderson Almeida (TOTVS NE)
  @version P12.1.17
  @since 31/03/2021	
/*/
//-------------------------------------------------------------------
Method sendVeiculos(pCodigo) Class PCLSFUSION
  Local nPrxId  := 0
  Local cCodigo := pCodigo
  Local cQuery  := ""

 // --- Pegar o próximo Id do FUSION
 // --------------------------------
  dbSelectArea("DA3")
  DA3->(dbSetOrder(1))
  
  If ! DA3->(dbSeek(FWxFilial("DA3") + cCodigo))
     ApMsgInfo("Veículo não cadastrado.","ATENÇÃO - Integração Fusion")

     Return .F.
  EndIf

  If DA3->DA3_XIDFUS == 0
     cQuery := "Select (Max(DA3_XIDFUS) + 1) as ID from " + RetSqlName("DA3")
     cQuery += "  where D_E_L_E_T_ <> '*'"
     cQuery += "    and DA3_FILIAL  = '" + FWxFilial("DA3") + "'"
     cQuery := ChangeQuery(cQuery)
     dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"QDA3",.F.,.T.)

     nPrxId := IIf(QDA3->ID == 0,1,QDA3->ID)

     QDA3->(dbCloseArea())
    
     Reclock("DA3",.F.)
       Replace DA3->DA3_XIDFUS with nPrxId
     DA3->(MsUnlock())
   else
     nPrxId := DA3->DA3_XIDFUS
  EndIf     
 // --------------------------------

  self:cBody := '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
  self:cBody += ' xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"'
  self:cBody += ' xmlns:urn="urn:myInputNamespace">'
  self:cBody += ' <soapenv:Header/>'
  self:cBody += ' <soapenv:Body>'
  self:cBody += '   <urn:sendVeiculos soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'
  self:cBody += '     <login xsi:type="xsd:string">' + self:cLogin + '</login>'
  self:cBody += '     <senha xsi:type="xsd:string">' + self:cPassword + '</senha>'
  self:cBody += '     <array_dados><![CDATA['
  self:cBody += '       ['  
  self:cBody += '        {'
  self:cBody += '          "campo_alt":"NEW_762",'
  self:cBody += '          "seq_id":"' + Str(nPrxId) + '",'
  self:cBody += '          "codigo_erp":"' + DA3->DA3_COD + '",'
  self:cBody += '          "placa":"' + DA3->DA3_PLACA + '",'
  self:cBody += '          "descricao":"' + FwNoAccent(AllTrim(DA3->DA3_DESC)) + '",'
  self:cBody += '          "kmAtual":"0",'
  self:cBody += '          "modelo":"' + FwNoAccent(AllTrim(Posicione("DUT",1,FWxFilial("DUT") + DA3->DA3_TIPVEI,"DUT_DESCRI"))) + '",'
  self:cBody += '          "anoModelo":"' + DA3->DA3_ANOMOD + '",'
  self:cBody += '          "anoFabricacao":"' + DA3->DA3_ANOFAB + '",'
  self:cBody += '          "qtdMaxEntregas":"0",'
  self:cBody += '          "velocidade_maxima":"80",'
  self:cBody += '          "tipo_combustivel":"",'
  self:cBody += '          "status_inicial":"Livre",'
  self:cBody += '          "peso_max_entregas":"' + Str(DA3->DA3_CAPACM) + '",'
  self:cBody += '          "volume_max_entregas":"' + Str(DA3->DA3_VOLMAX) + '",'
  self:cBody += '          "qtd_pallets_veiculo":"' + Str(DA3->DA3_QTDUNI) + '"'
  self:cBody += '        }'
  self:cBody += '       ]'
  self:cBody += '       ]]>'
  self:cBody += '     </array_dados>'
  self:cBody += '   </urn:sendVeiculos>'
  self:cBody += ' </soapenv:Body>'
  self:cBody += '</soapenv:Envelope>'

  MemoWrite("C:\Temp\Veiculo.xml",self:cBody)

Return .T.

//-------------------------------------------------------------------
/*/{protheusDoc.marcadores_ocultos} PCLSFUSION
  Objeto sendMotoristas
  
    Montagem do Cadastro de Motorista

  @author Anderson Almeida (TOTVS NE)
  @version P12.1.17
  @since 31/03/2021	
/*/
//-------------------------------------------------------------------
Method sendMotoristas(pCodigo) Class PCLSFUSION
  Local cCodigo := pCodigo

 // --- Posicionar Motoristas
 // -------------------------
  dbSelectArea("DA4")
  DA4->(dbSetOrder(1))
  
  If ! DA4->(dbSeek(FWxFilial("DA4") + cCodigo))
     ApMsgInfo("Motorista não cadastrado.","ATENÇÃO - Integração Fusion")

     Return .F.
  EndIf
 // --------------------------
 
  self:cBody := '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
  self:cBody += ' xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"'
  self:cBody += ' xmlns:urn="urn:myInputNamespace">'
  self:cBody += ' <soapenv:Header/>'
  self:cBody += ' <soapenv:Body>'
  self:cBody += '   <urn:sendMotoristas soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'
  self:cBody += '     <login xsi:type="xsd:string">' + self:cLogin + '</login>'
  self:cBody += '     <senha xsi:type="xsd:string">' + self:cPassword + '</senha>'
  self:cBody += '     <array_dados><![CDATA['
  self:cBody += '        ['  
  self:cBody += '         {'
  self:cBody += '          "campo_alt":"NEW_825",'
  self:cBody += '          "seq_id":"' + DA4->DA4_COD + '",'
  self:cBody += '          "codigo_erp":"' + DA4->DA4_COD + '",'
  self:cBody += '          "nome":"' + FwNoAccent(AllTrim(DA4->DA4_NOME)) + '",'
  self:cBody += '          "cpf":"' + DA4->DA4_CGC + '",'
  self:cBody += '          "cep":"' + AllTrim(DA4->DA4_CEP) + '",'
  self:cBody += '          "endereco":"' + FwNoAccent(AllTrim(DA4->DA4_END)) + '",'
  self:cBody += '          "cidade":"' + FwNoAccent(AllTrim(DA4->DA4_MUN)) + '",'
  self:cBody += '          "uf":"' + DA4->DA4_EST + '",'
  self:cBody += '          "telefone":"' + AllTrim(DA4->DA4_TEL) + '",'
  self:cBody += '          "tipo":"Motorista",'
  self:cBody += '          "valor_hr_extra_normal":0.00,'
  self:cBody += '          "valor_hr_encargos":0.00,'
  self:cBody += '          "adiantamento":0.00,'
  self:cBody += '          "negociar_frete":"N",'
  self:cBody += '          "email":"",'
  self:cBody += '          "telefone2":"' + AllTrim(DA4->DA4_TELREC) + '",'
  self:cBody += '          "telefone3":""'
  self:cBody += '        }'
  self:cBody += '       ]'
  self:cBody += '       ]]>'
  self:cBody += '     </array_dados>'
  self:cBody += '   </urn:sendMotoristas>'
  self:cBody += ' </soapenv:Body>'
  self:cBody += '</soapenv:Envelope>'

  MemoWrite("C:\Temp\Motorista.xml",self:cBody)

Return .T.

//-------------------------------------------------------------------
/*/{protheusDoc.marcadores_ocultos} PCLSFUSION
  Objeto sendAjudantes
  
    Montagem do Cadastro de Ajudantes

  @author Anderson Almeida (TOTVS NE)
  @version P12.1.17
  @since 31/03/2021	
/*/
//-------------------------------------------------------------------
Method sendAjudantes(pCodigo) Class PCLSFUSION
  Local cCodigo := pCodigo

 // --- Posicionar Motoristas
 // -------------------------
  dbSelectArea("DAU")
  DAU->(dbSetOrder(1))
  
  If ! DAU->(dbSeek(FWxFilial("DAU") + cCodigo))
     ApMsgInfo("Ajudante não cadastrado.","ATENÇÃO - Integração Fusion")

     Return .F.
  EndIf
 // --------------------------

  self:cBody := '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
  self:cBody += ' xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"'
  self:cBody += ' xmlns:urn="urn:myInputNamespace">'
  self:cBody += ' <soapenv:Header/>'
  self:cBody += ' <soapenv:Body>'
  self:cBody += '   <urn:sendMotoristas soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'
  self:cBody += '     <login xsi:type="xsd:string">' + self:cLogin + '</login>'
  self:cBody += '     <senha xsi:type="xsd:string">' + self:cPassword + '</senha>'
  self:cBody += '     <array_dados><![CDATA['
  self:cBody += '        ['  
  self:cBody += '         {'
  self:cBody += '          "campo_alt":"NEW_825",'
  self:cBody += '          "seq_id":"' + DAU->DAU_COD + '",'
  self:cBody += '          "codigo_erp":"' + DAU->DAU_COD + '",'
  self:cBody += '          "nome":"' + FwNoAccent(AllTrim(DAU->DAU_NOME)) + '",'
  self:cBody += '          "cpf":"' + DAU->DAU_CGC + '",'
  self:cBody += '          "cep":"' + AllTrim(DAU->DAU_CEP) + '",'
  self:cBody += '          "endereco":"' + FwNoAccent(AllTrim(DAU->DAU_END)) + '",'
  self:cBody += '          "cidade":"' + FwNoAccent(AllTrim(DAU->DAU_MUN)) + '",'
  self:cBody += '          "uf":"' + DAU->DAU_EST + '",'
  self:cBody += '          "telefone":"' + AllTrim(DAU->DAU_TEL) + '",'
  self:cBody += '          "tipo":"Ajudante",'
  self:cBody += '          "valor_hr_extra_normal":0.00,'
  self:cBody += '          "valor_hr_encargos":0.00,'
  self:cBody += '          "adiantamento":0.00,'
  self:cBody += '          "negociar_frete":"N",'
  self:cBody += '          "email":"",'
  self:cBody += '          "telefone2":"",'
  self:cBody += '          "telefone3":""'
  self:cBody += '        }'
  self:cBody += '       ]'
  self:cBody += '       ]]>'
  self:cBody += '     </array_dados>'
  self:cBody += '   </urn:sendMotoristas>'
  self:cBody += ' </soapenv:Body>'
  self:cBody += '</soapenv:Envelope>'

  MemoWrite("C:\Temp\Ajudante.xml",self:cBody)
Return .T.

//-------------------------------------------------------------------
/*/{protheusDoc.marcadores_ocultos} PCLSFUSION
  Objeto LerPedidoVenda
  
  Ler Pedido de Venda

  @parámetro pPedido   - Número do Pedido de Venda
             pSeq      - Sequencial do pedido. Para o primeiro é "0"
                         e não manda para a FUSION o sequencial
             pBloq     - .T. precisa validar se o pedido está bloqueado
                         .F. precisa validar se o pedido está liberado
             pExcluido - .T. pedido excluido ou .F. não
             
  @author Anderson Almeida (TOTVS NE)
  @version P12.1.17
  @since 31/03/2021	
/*/
//-------------------------------------------------------------------
Method LerPedidoVenda(pPedido,pSeq,pSC5,pExcluido) Class PCLSFUSION
  Local cC5Num    := pPedido
  Local nSeq      := pSeq
  Local lLerSC5   := pSC5
  Local lExcluido := pExcluido
  Local aRet      := {.T.,"",{},{}}
  Local aRegLib   := {}
  Local aRegBloq  := {}
  Local cQuery    := ""
  Local cDsRegiao := ""
  Local nLPeso    := 0
  Local nLCubagem := 0
  Local nLTtVend  := 0
  Local nBPeso    := 0
  Local nBCubagem := 0
  Local nBTtVend  := 0

  If ! lExcluido
     dbSelectArea("SC5")
     SC5->(dbSetOrder(1))

     If ! SC5->(dbSeek(SC5->C5_FILIAL + cC5Num))
        aRet[01] := .F.
        aRet[02] := "Pedido Venda não encontrado."

        Return aRet
     EndIf
  EndIf
  // If Empty(SC5->C5_LIBEROK)
  If lLerSC5
     cQuery := "Select SC6.C6_PRODUTO as PRODUTO, SC6.C6_QTDVEN as QTDE, SC6.C6_PRCVEN as PRCVEN,"
     cQuery += "       '' as CARGA, SB1.B1_DESC, SB1.B1_UM, SB1.B1_POSIPI, SB1.B1_PESO, SB5.B5_ALTURLC,"
     cQuery += "       SB5.B5_COMPRLC, SB5.B5_LARGLC, 'B' as BLOQ"
     cQuery += "  from " + RetSqlName("SC6") + " SC6, " + RetSqlName("SB1") + " SB1, " + RetSqlName("SB5") + " SB5"
     cQuery += "   where SC6.C6_FILIAL  = '" + SC5->C5_FILIAL + "'"

     If ! lExcluido
        cQuery += " and SC6.D_E_L_E_T_ <> '*'"
     EndIf

     cQuery += "     and SC6.C6_NUM     = '" + SC5->C5_NUM + "'"
     cQuery += "     and SB1.D_E_L_E_T_ <> '*'"
     cQuery += "     and SB1.B1_FILIAL  = '" + xFilial("SB1") + "'"
     cQuery += "     and SB1.B1_COD     = SC6.C6_PRODUTO"
   else
     cQuery := "Select SC9.C9_PRODUTO as PRODUTO, SC9.C9_QTDLIB as QTDE, SC9.C9_PRCVEN as PRCVEN,"
     cQuery += "       SC9.C9_CARGA as CARGA, SB1.B1_DESC, SB1.B1_UM, SB1.B1_POSIPI, SB1.B1_PESO,"
     cQuery += "       SB5.B5_ALTURLC, SB5.B5_COMPRLC, SB5.B5_LARGLC, SC9.C9_NFISCAL,"
     cQuery += "       Case when ((SC9.C9_BLCRED <> '10' and SC9.C9_BLCRED <> '') or"
     cQuery += "                  (SC9.C9_BLEST <> '10' and SC9.C9_BLEST <> ''))"
     cQuery += "             Then 'B' else 'L' end BLOQ, SC9.R_E_C_N_O_ as RECNO"
     cQuery += "  from " + RetSqlName("SC9") + " SC9, " + RetSqlName("SB1") + " SB1, " + RetSqlName("SB5") + " SB5"
     cQuery += "   where SC9.D_E_L_E_T_ <> '*'"
     cQuery += "     and SC9.C9_FILIAL  = '" + SC5->C5_FILIAL + "'"
     cQuery += "     and SC9.C9_PEDIDO  = '" + SC5->C5_NUM + "'"
     /*
      If !(AllTrim(FunName()) $ ("MATA460A/MATA460B/OMSA200"))
      cQuery += "     and SC9.C9_CARGA   = ' '"
      cQuery += "     and SC9.C9_NFISCAL = ' '"
      
      If Empty(SC5->C5_XSEQFUS) .or. AllTrim(FunName()) == "MATA410"
        cQuery += " and SC9.C9_XSEQFUS = '" + SC5->C5_XSEQFUS + "'"
      ElseIf !IsInCallStack("U_PFUSCARGAINI") .And. !IsInCallStack("U_M460FIM")
        cQuery += " and SC9.C9_XSEQFUS <> '" + SC5->C5_XSEQFUS + "'"
      EndIf
     
     EndIF 
     */
     cQuery += "     and SB1.D_E_L_E_T_ <> '*'"
     cQuery += "     and SB1.B1_FILIAL  = '" + xFilial("SB1") + "'"
     cQuery += "     and SB1.B1_COD     = SC9.C9_PRODUTO"
  EndIf   

  cQuery += "     and SB5.D_E_L_E_T_ <> '*'"
  cQuery += "     and SB5.B5_FILIAL  = '" + xFilial("SB5") + "'"
  cQuery += "     and SB5.B5_COD     = SB1.B1_COD"
  cQuery := ChangeQuery(cQuery)
  dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"QPSQ",.F.,.T.)     
  MemoWrite("c:\Temp\QPSQ.txt",cQuery)
  
  If QPSQ->(Eof())
     aRet[01] := .F.
     aRet[02] := "Não existe registro a ser enviado ao FUSION."

     QPSQ->(dbCloseArea())

     Return aRet
  EndIf

  dbSelectArea("SA1")
  SA1->(dbSetOrder(1))
  
  If ! SA1->(dbSeek(FWxFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI))
     aRet[01] := .F.
     aRet[02] := "Verificar o cadastro de cliente do pedido."

     QPSQ->(dbCloseArea())
     
     Return aRet
  EndIf  

  cDsRegiao := AllTrim(Posicione("SX5",1,FWxFilial("SX5") + "A2" + SC5->C5_XREGIAO,"X5_DESCRI"))

  While ! QPSQ->(Eof()) 
    If QPSQ->BLOQ == "L"
       aAdd(aRegLib,{QPSQ->PRODUTO,;                         // 01 - Produto
                     QPSQ->B1_DESC,;                         // 02 - Descrição
                     QPSQ->B1_UM,;                           // 03 - Unidade do Produto 
                     QPSQ->QTDE,;                            // 04 - Quantidade liberada
                     (QPSQ->QTDE * QPSQ->B1_PESO),;          // 05 - Peso
                     QPSQ->PRCVEN,;                          // 06 - Valor unitário
                     (QPSQ->QTDE * QPSQ->PRCVEN),;           // 07 - Total
                     0,;                                     // 08 - Valor ICMS ST
                     QPSQ->B1_POSIPI,;                       // 09 - NCM
                     0,;                                     // 10 - CST
                     FwNoAccent(Alltrim(SC5->C5_MENNOTA)),;  // 11 - Observação
                     0,;                                     // 12 - Peso total
                     0,;                                     // 13 - Cubagem total
                     0,;                                     // 14 - Total da Venda
                     SC5->C5_NUM,;                           // 15 - Número do Pedido
                     SC5->C5_CLIENTE,;                       // 16 - Código do Cliente
                     SC5->C5_LOJACLI,;                       // 17 - Loja do Cliente
                     SC5->C5_VEND1,;                         // 18 - Código do Vendedor
                     SC5->C5_EMISSAO,;                       // 19 - Data da emissão do pedido
                     nSeq,;                                  // 20 - Sequencial da FUSION
                     QPSQ->CARGA,;                           // 21 - Número da Carga
                     SC5->C5_XREGIAO,;                       // 22 - Código da Região
                     cDsRegiao,;                             // 23 - Descrição da Região
                     QPSQ->RECNO,;                           // 24 - Número do registro
                     'L'})                                   // 25 - Status do item (L-Liberado/B-Bloqueado)

       nLPeso    += (QPSQ->QTDE * QPSQ->B1_PESO)
       nLCubagem += QPSQ->QTDE * (QPSQ->B5_COMPRLC * QPSQ->B5_ALTURLC * QPSQ->B5_LARGLC)
       nLTtVend  += (QPSQ->PRCVEN * QPSQ->QTDE)

      If Type("cStatusFUS") == "C"
         cStatusFUS := "1" //Status Liberado
      EndIf 

     else
       aAdd(aRegBloq,{QPSQ->PRODUTO,;                         // 01 - Produto
                      QPSQ->B1_DESC,;                         // 02 - Descrição
                      QPSQ->B1_UM,;                           // 03 - Unidade do Produto 
                      QPSQ->QTDE,;                            // 04 - Quantidade liberada
                      (QPSQ->QTDE * QPSQ->B1_PESO),;          // 05 - Peso
                      QPSQ->PRCVEN,;                          // 06 - Valor unitário
                      (QPSQ->QTDE * QPSQ->PRCVEN),;           // 07 - Total
                      0,;                                     // 08 - Valor ICMS ST
                      QPSQ->B1_POSIPI,;                       // 09 - NCM
                      0,;                                     // 10 - CST
                      FwNoAccent(Alltrim(SC5->C5_MENNOTA)),;  // 11 - Observação
                      0,;                                     // 12 - Peso total
                      0,;                                     // 13 - Cubagem total
                      0,;                                     // 14 - Total da Venda
                      SC5->C5_NUM,;                           // 15 - Número do Pedido
                      SC5->C5_CLIENTE,;                       // 16 - Código do Cliente
                      SC5->C5_LOJACLI,;                       // 17 - Loja do Cliente
                      SC5->C5_VEND1,;                         // 18 - Código do Vendedor
                      SC5->C5_EMISSAO,;                       // 19 - Data da emissão do pedido
                      nSeq,;                                  // 20 - Sequencial da FUSION
                      QPSQ->CARGA,;                           // 21 - Número da Carga
                      SC5->C5_XREGIAO,;                       // 22 - Código da Região
                      cDsRegiao,;                             // 23 - Descrição da Região
                      0,;                                     // 24 - Número do registro
                      'B'})                                   // 25 - Status do item (L-Liberado/B-Bloqueado)
       nBPeso    += (QPSQ->QTDE * QPSQ->B1_PESO)
       nBCubagem += QPSQ->QTDE * (QPSQ->B5_COMPRLC * QPSQ->B5_ALTURLC * QPSQ->B5_LARGLC)
       nBTtVend  += (QPSQ->PRCVEN * QPSQ->QTDE)

      If Type("cStatusFUS") == "C"
        If Empty(cStatusFUS) .Or. cStatusFUS == "0"
          cStatusFUS := "B" //Status Bloqueado
        EndIf 
      EndIf

    EndIf  

    QPSQ->(dbSkip())
  EndDo
 
  QPSQ->(dbCloseArea())

 // -- Item Liberados
 // -----------------
  If Len(aRegLib) > 0
     aRegLib[01][12] := nLPeso
     aRegLib[01][13] := nLCubagem
     aRegLib[01][14] := nLTtVend
  EndIf

 // -- Itens Bloqueados
 // ------------------- 
  If Len(aRegBloq) > 0
     aRegBloq[01][12] := nBPeso
     aRegBloq[01][13] := nBCubagem
     aRegBloq[01][14] := nBTtVend
  EndIf

  aRet[03] := aRegBloq
  aRet[04] := aRegLib
Return aRet

//-------------------------------------------------
/*/{protheusDoc.marcadores_ocultos} PCLSFUSION
  Montar a requisição do pedido de venda

  @Parâmetro: pStatus  - 'N' = Normal
                         'B' = Bloqueado
              pForma   - 'S' = Sim forma carga
                         'N' = Não forma carga 
              lCarga   - .T. = Número da carga
                         .F. = Sem número da carga 
              pNFiscal - Número da Nota Fiscal do Pedido de Venda
              pSerieNF - Série da Nota Fiscal do Pedido de Venda

  @author Anderson Almeida (TOTVS NE)
  @since 02/04/2021	
  @since 02/05/2023 (Cubagem) Elvis Siqueira
  @since 11/12/2023 (Condição de Pagamento + Número da Nota Fiscal) Elvis Siqueira
  @since 24/03/2024 (Envio do número da carga quando realizada manutencao na carga) Elvis Siqueira
/*/
//-------------------------------------------------
Method saveEntregaServico(pStatus, pForma, lCarga, pNFiscal, pSerieNF) Class PCLSFUSION 
  Local cStatusFUS := pStatus  // N - Normal ou B - Bloqueado
  Local nId       := 0
  Local cPedido   := ""
  //Local cPedOrig  := ""
  Local cCondPag  := Alltrim(Posicione("SE4",1,FWxFilial("SE4")+SC5->C5_CONDPAG,"E4_DESCRI"))
  Local lEnvBlq   := SuperGetMV("MV_XENVBLQ",.F.,.F.)
  Local cFilFus   := ""
  Local _cAliasC9 := "TSC9"+FWTimeStamp(1)
  Local cQrySC9   := ""

  Default cNFiscal := IIF(ValType(pNFiscal) != "U", pNFiscal, Alltrim(SC5->C5_NOTA))
  Default cSerieNF := IIF(ValType(pSerieNF) != "U", pSerieNF, Alltrim(SC5->C5_SERIE))

  IF lCarga
    cQrySC9 := " SELECT * FROM "+ RetSqlName("SC9") +" SC9 "
    cQrySC9 += " WHERE D_E_L_E_T_ <> '*' "
    cQrySC9 += "   AND	C9_FILIAL  = '" + SC5->C5_FILIAL +"' "
    cQrySC9 += "   AND	C9_PEDIDO  = '" + SC5->C5_NUM +"' "
    cQrySC9 := ChangeQuery(cQrySC9)
    IF Select(_cAliasC9) <> 0
        (_cAliasC9)->(DbCloseArea())
    EndIf
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySC9),_cAliasC9,.T.,.T.)
    While (_cAliasC9)->(!Eof())
        If !Empty((_cAliasC9)->C9_CARGA)
          self:aRegistro[01][21] := (_cAliasC9)->C9_CARGA
          Exit
        EndIf
        (_cAliasC9)->(DBSkip())
    EndDo
    IF Select(_cAliasC9) <> 0
        (_cAliasC9)->(DbCloseArea())
    EndIf
  EndIf

  If FWSM0Util():GetSM0Data(cEmpAnt , cFilAnt , { "M0_ESTENT" })[1,2] == "PE"
    Do Case
      Case SC5->C5_FILIAL == SC5->C5_XFPVOP
        cFilFus := SC5->C5_FILIAL
      Case Empty(SC5->C5_XFPVOP)
        cFilFus := SC5->C5_FILIAL
      Case SC5->C5_FILIAL != SC5->C5_XFPVOP
        cFilFus := SC5->C5_XFPVOP
    EndCase 
  Else
    cFilFus := SC5->C5_FILIAL
  EndIF

  If self:aRegistro[01][20] == 0
    cPedido  := IIF(!Empty(self:aRegistro[01][15]), cFilFus + "_" + self:aRegistro[01][15],"")
    //cPedOrig := IIF(!Empty(SC5->C5_XFPVOP) .AND. !Empty(SC5->C5_XNUMORI),SC5->C5_XFPVOP+"_"+SC5->C5_XNUMORI,cPedido)
   else
    cPedido  := IIF(!Empty(self:aRegistro[01][15]), cFilFus + "_" + self:aRegistro[01][15] + "_" + StrZero(self:aRegistro[01][20],TamSX3("C5_XSEQFUS")[1]),"")
    //cPedOrig := IIF(!Empty(SC5->C5_XFPVOP) .AND. !Empty(SC5->C5_XNUMORI),SC5->C5_XFPVOP+"_"+SC5->C5_XNUMORI,cPedido)
  EndIf

  dbSelectArea("SA1")
  SA1->(dbSetOrder(1))
  SA1->(dbSeek(FWxFilial("SA1") + self:aRegistro[01][16] + self:aRegistro[01][17]))

  self:cBody := '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
  self:cBody += ' xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"'
  self:cBody += ' xmlns:urn="urn:myInputNamespace">'
  self:cBody += ' <soapenv:Header/>'
  self:cBody += ' <soapenv:Body>'
  self:cBody += '   <urn:saveEntregaServico soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'
  self:cBody += '     <login xsi:type="xsd:string">' + self:cLogin + '</login>'
  self:cBody += '     <senha xsi:type="xsd:string">' + self:cPassword + '</senha>'
  self:cBody += '     <array_dados><![CDATA['
  self:cBody += '        ['  
  self:cBody += '         {'
  self:cBody += '          "nf": "'+Alltrim(cNFiscal)+'",'
  self:cBody += '          "serie": "'+Alltrim(cSerieNF)+'",'
  self:cBody += '          "tipo": "",'
  self:cBody += '          "ent_ou_serv": "Entrega",'
  self:cBody += '          "pedido_erp": "' + cPedido + '",'
  self:cBody += '          "forma_pgto": "'+cCondPag+'",'
  self:cBody += '          "status": "' + cStatusFUS + '",'
  self:cBody += '          "obs": "",'
  self:cBody += '          "num_ped_conf": "' + cPedido + '",'
  self:cBody += '          "carga": "' + IIf(lCarga, IIF(!Empty(self:aRegistro[01][21]), cFilFus+"_"+self:aRegistro[01][21],""), "") + '",'
  If self:aRegistro[01][13] > 0 
    self:cBody += '        "cubagem": "' + AllTrim(Str(self:aRegistro[01][13])) + '",'
  else
    self:cBody += '        "cubagem": "' + "0.000001" + '",'
  EndIf 
  self:cBody += '          "podeformarcarga": "' + pForma + '",'
  self:cBody += '          "valor": "' + AllTrim(Str(self:aRegistro[01][14],16,2)) + '",'
  self:cBody += '          "peso": "' + AllTrim(Str(self:aRegistro[01][12],16,2)) + '",'
  self:cBody += '          "valor_st": "0",'
  self:cBody += '          "empresa_fat": "' + cFilFus + '",'
  self:cBody += '          "empresa_log": "' + cFilFus + '",'
  self:cBody += '          "empresa_digit": "' + cFilFus + '",'
  self:cBody += '          "pedido_orig": "' + cPedido + '",'
  self:cBody += '          "dt_list_nf": "' + AllTrim(Str(Year(IIF(Empty(SC5->C5_SUGENT),dDataBase,SC5->C5_SUGENT))) + "-" +;
                                                      StrZero(Month(IIF(Empty(SC5->C5_SUGENT),dDataBase,SC5->C5_SUGENT)),2) + '-' +;
                                                      StrZero(Day(IIF(Empty(SC5->C5_SUGENT),dDataBase,SC5->C5_SUGENT)),2) + " " + Time()) + '",'
  self:cBody += '          "data_alt": "2021-12-09 12:14:37",'
  self:cBody += '          "nf_cod_rota_erp": "' + self:aRegistro[01][22] + '",'
  self:cBody += '          "nf_descricao_rota": "' + FwNoAccent(self:aRegistro[01][23]) + '",'
  self:cBody += '          "descr_cliente": "' + FwNoAccent(AllTrim(SA1->A1_NREDUZ)) + '",'
  self:cBody += '          "razao_cliente": "' + FwNoAccent(AllTrim(SA1->A1_NOME)) + '",'
  self:cBody += '          "cnpj_cliente": "' + AllTrim(SA1->A1_CGC) + '",'
  self:cBody += '          "end_cliente": "' + FwNoAccent(Alltrim(IIF(!Empty(SA1->A1_ENDENT),SA1->A1_ENDENT,SA1->A1_END))) + '",'
  self:cBody += '          "bairro_cliente": "' + FwNoAccent(Alltrim(IIF(!Empty(SA1->A1_BAIRROE),SA1->A1_BAIRROE,SA1->A1_BAIRRO))) + '",'
  self:cBody += '          "num_end_cliente": "' + AllTrim(SA1->A1_XNUMEND) + '",'
  self:cBody += '          "uf_cliente": "' + IIF(!Empty(SA1->A1_ESTE),SA1->A1_ESTE,SA1->A1_EST) + '",'
  self:cBody += '          "cidade_cliente": "' + FwNoAccent(Alltrim(IIF(!Empty(SA1->A1_MUNE),SA1->A1_MUNE,SA1->A1_MUN))) + '",'
  self:cBody += '          "cep_cliente": "' + IIF(!Empty(SA1->A1_CEPE),SA1->A1_CEPE,SA1->A1_CEP) + '",'
  self:cBody += '          "email1_cliente": "' + FwNoAccent(AllTrim(SA1->A1_EMAIL)) + '",'
  self:cBody += '          "email2_cliente": "",'
  self:cBody += '          "email3_cliente": "",'
  self:cBody += '          "tel1_cliente": "' + AllTrim(SA1->A1_TEL) + '",'
  self:cBody += '          "tel2_cliente": "",'
  self:cBody += '          "tel3_cliente": "",'
  self:cBody += '          "vlr_credito_cliente": "0",'
  self:cBody += '          "data_cadastro_cliente": "' + AllTrim(Str(Year(dDataBase)) + "-" + StrZero(Month(dDataBase),2) +;
                                                                 '-' + StrZero(Day(dDataBase),2) + " " + Time()) + '",'
  self:cBody += '          "saldo_disp_cliente": "0",'
  self:cBody += '          "vlr_tits_vencido_cliente": "0",'
  self:cBody += '          "vlr_tits_vencer_cliente": "0",'
  self:cBody += '          "status_cred_cliente": "C",'
  self:cBody += '          "codigo_cliente": "' + AllTrim(SA1->A1_COD) + AllTrim(SA1->A1_LOJA) + '",'
  self:cBody += '          "cod_segmento": "2",'
  self:cBody += '          "descr_segmento": "ATACADO",'
  self:cBody += '          "filial_padrao": "' + cFilFus + '",'
  self:cBody += '          "data_ult_compra": "' + AllTrim(Str(Year(dDataBase))) + "-" + StrZero(Month(dDataBase),2) +;
                                             '-' + StrZero(Day(dDataBase),2) + " " + Time() + '",'
  self:cBody += '          "forma_pgto_cliente": "1",'
  self:cBody += '          "retem_icms_cliente": "N",'
  self:cBody += '          "permite_retira_cliente": "N",'
  self:cBody += '          "rede_loja_cliente": "' + SA1->A1_LOJA + '",'
  self:cBody += '          "rota_cod_erp": "' + self:aRegistro[01][22] + '",'
  self:cBody += '          "rota_descricao": "' + FwNoAccent(self:aRegistro[01][23]) + '",'
  self:cBody += '          "praca_cod_erp": "' + self:aRegistro[01][22] + '",'
  self:cBody += '          "praca_descricao": "' + FwNoAccent(self:aRegistro[01][23]) + '",'
  self:cBody += '          "vendedor_erp": "' + FwNoAccent(Posicione("SA3",1,FWxFilial("SA3") + self:aRegistro[01][18],"A3_NREDUZ")) + '",'
  self:cBody += '          "data_pedido": "' + AllTrim(Str(Year(self:aRegistro[01][19])) + "-" +;
                                                       StrZero(Month(self:aRegistro[01][19]),2) +;
                                                       '-' + StrZero(Day(self:aRegistro[01][19]),2) + " " + Time()) + '",'
  self:cBody += '          "codigo_endereco_alt": "",'
  self:cBody += '          "referencia_entrega": "",'
  self:cBody += '          "restricao_transp": "N",'
  self:cBody += '          "prioridade": "N",'
  self:cBody += '          "latitude": 0,'
  self:cBody += '          "longitude": 0,'
  self:cBody += '          "itens":'
  self:cBody += '             ['

  For nId := 1 To Len(self:aRegistro)
      
      If lEnvBlq //Envia produtos bloqueados
        
        self:cBody += '  {'
        self:cBody += '   "cod_produto_erp": "' + self:aRegistro[nId][01] + '",'
        self:cBody += '   "descricao": "' + AllTrim(FwNoAccent(self:aRegistro[nId][02])) + '",'
        self:cBody += '   "unidade": "' + self:aRegistro[nId][03] + '",'
        self:cBody += '   "qtd": "' + AllTrim(Str(self:aRegistro[nId][04])) + '",'
        self:cBody += '   "peso": "' + AllTrim(Str(self:aRegistro[nId][05],16,2)) + '",'
        self:cBody += '   "preco": "' + AllTrim(Str(self:aRegistro[nId][06],16,2)) + '",'
        self:cBody += '   "subtotal": "' + AllTrim(Str(self:aRegistro[nId][07],16,2)) + '",'
        self:cBody += '   "valor_icms_st": "' + AllTrim(Str(self:aRegistro[nId][08])) + '",'
        self:cBody += '   "ncm": "' + self:aRegistro[nId][09] + '",'
        self:cBody += '   "cst": "' + Str(self:aRegistro[nId][10]) + '",'
        self:cBody += '   "obs_item": "' + FwNoAccent(AllTrim(self:aRegistro[nId][11])) + '"'
        self:cBody += '  }' + IIf(nId < Len(self:aRegistro),',','') 
      
      ElseIF !lEnvBlq .AND. self:aRegistro[nId][25] == 'L' //Só envia produtos liberados
        
        self:cBody += '  {'
        self:cBody += '   "cod_produto_erp": "' + self:aRegistro[nId][01] + '",'
        self:cBody += '   "descricao": "' + AllTrim(FwNoAccent(self:aRegistro[nId][02])) + '",'
        self:cBody += '   "unidade": "' + self:aRegistro[nId][03] + '",'
        self:cBody += '   "qtd": "' + AllTrim(Str(self:aRegistro[nId][04])) + '",'
        self:cBody += '   "peso": "' + AllTrim(Str(self:aRegistro[nId][05],16,2)) + '",'
        self:cBody += '   "preco": "' + AllTrim(Str(self:aRegistro[nId][06],16,2)) + '",'
        self:cBody += '   "subtotal": "' + AllTrim(Str(self:aRegistro[nId][07],16,2)) + '",'
        self:cBody += '   "valor_icms_st": "' + AllTrim(Str(self:aRegistro[nId][08])) + '",'
        self:cBody += '   "ncm": "' + self:aRegistro[nId][09] + '",'
        self:cBody += '   "cst": "' + Str(self:aRegistro[nId][10]) + '",'
        self:cBody += '   "obs_item": "' + FwNoAccent(AllTrim(self:aRegistro[nId][11])) + '"'
        self:cBody += '  }' + IIf(nId < Len(self:aRegistro),',','')
      
      EndIF 
  
  Next

  self:cBody += '         ],'
  self:cBody += '         "titulos": [ { } ]'
  self:cBody += '        }'
  self:cBody += '       ]'
  self:cBody += '      ]]>'
  self:cBody += '     </array_dados>'
  self:cBody += '   </urn:saveEntregaServico>'
  self:cBody += ' </soapenv:Body>'
  self:cBody += '</soapenv:Envelope>'
  
  MemoWrite("C:\Temp\Pedido.xml",self:cBody)

Return

//----------------------------------------------
/*/{protheusDoc.marcadores_ocultos} PCLSFUSION
  Montar a requisição do detalhe Carga

  @author Anderson Almeida (TOTVS NE)
  @since 02/04/2021	
/*/
//----------------------------------------------
Method detalheCarga(pCarga, pDtInicio, pDtFim) Class PCLSFUSION 
  Local cInicio := AllTrim(Str(Year(pDtInicio))) + '-' + StrZero(Month(pDtInicio),2) + '-' + StrZero(Day(pDtInicio),2)
  Local cFim    := AllTrim(Str(Year(pDtFim))) + '-' + StrZero(Month(pDtFim),2) + '-' + StrZero(Day(pDtFim),2)
   
  self:cBody := '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
  self:cBody += '   xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"'
  self:cBody += '   xmlns:urn="urn:myInputNamespace">'
  self:cBody += ' <soapenv:Header/>'
  self:cBody += '  <soapenv:Body>'
  self:cBody += '    <urn:detalheCarga soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'
  self:cBody += '      <login xsi:type="xsd:string">' + self:cLogin + '</login>'
  self:cBody += '      <senha xsi:type="xsd:string">' + self:cPassword + '</senha>'
  self:cBody += '      <carga xsi:type="xsd:string">' + pCarga + '</carga>'
  self:cBody += '      <sn_romaneio xsi:type="xsd:string"></sn_romaneio>'
  self:cBody += '      <data_inicio xsi:type="xsd:string">' + cInicio + '</data_inicio>'
  self:cBody += '      <data_fim xsi:type="xsd:string">' + cFim + '</data_fim>'
  self:cBody += '    </urn:detalheCarga>'
  self:cBody += '  </soapenv:Body>'
  self:cBody += '</soapenv:Envelope>'

  MemoWrite("C:\Temp\DetalheCarga.xml",self:cBody)

Return

//-----------------------------------------------
/*/{protheusDoc.marcadores_ocultos} PCLSFUSION
  Montar a requisição para importar carga.

  @author Anderson Almeida (TOTVS NE)
  @since 28/06/2021	
/*/
//-----------------------------------------------
Method getIntErpFilial(pFilial) Class PCLSFUSION

  self:cBody := '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
  self:cBody += '   xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"'
  self:cBody += '   xmlns:urn="urn:myInputNamespace">'
  self:cBody += ' <soapenv:Header/>'
  self:cBody += '  <soapenv:Body>'
  self:cBody += '    <urn:getIntErpFilial soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'
  self:cBody += '      <login xsi:type="xsd:string">' + self:cLogin + '</login>'
  self:cBody += '      <senha xsi:type="xsd:string">' + self:cPassword + '</senha>'
  self:cBody += '      <filial xsi:type="xsd:string">' + pFilial + '</filial>'
  self:cBody += '      <limite_padrao xsi:type="xsd:string">999</limite_padrao>'
  self:cBody += '    </urn:getIntErpFilial>'
  self:cBody += '  </soapenv:Body>'
  self:cBody += ' </soapenv:Envelope>'

  MemoWrite("C:\Temp\ImportaCarga.xml",self:cBody)

Return

//-----------------------------------------------
/*/{protheusDoc.marcadores_ocultos} PCLSFUSION
  Montar a requisição para informar ao FUSION
  a gravação da carga no PROTHEUS.

  @author Anderson Almeida (TOTVS NE)
  @since 28/06/2021	
/*/
//-----------------------------------------------
Method setIntErp(pIntId, pCarga) Class PCLSFUSION 
  self:cBody := '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
  self:cBody += '   xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"'
  self:cBody += '   xmlns:urn="urn:myInputNamespace">'
  self:cBody += ' <soapenv:Header/>'
  self:cBody += '  <soapenv:Body>'
  self:cBody += '    <urn:setIntErp soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'
  self:cBody += '      <login xsi:type="xsd:string">' + self:cLogin + '</login>'
  self:cBody += '      <senha xsi:type="xsd:string">' + self:cPassword + '</senha>'
  self:cBody += '      <int_id xsi:type="xsd:string">' + pIntId + '</int_id>'
  self:cBody += '      <retorno_carga xsi:type="xsd:string"></retorno_carga>'
  self:cBody += '      <carga xsi:type="xsd:string">' + pCarga + '</carga>'
  self:cBody += '      <lista_int xsi:type="xsd:string"></lista_int>'
  self:cBody += '      <atualizaCargaDaEntrega xsi:type="xsd:string">N</atualizaCargaDaEntrega>'
  self:cBody += '    </urn:setIntErp>'
  self:cBody += ' </soapenv:Body>'
  self:cBody += '</soapenv:Envelope>'

  MemoWrite("C:\Temp\GravaCarga.xml",self:cBody)

Return

//-----------------------------------------------
/*/{protheusDoc.marcadores_ocultos} PCLSFUSION
  Montar a requisição e Enviar para o FUSION as
  alterações de Veiculo e Motorista da carga.

  @author Elvis Siqueira (TOTVS NE)
  @since 18/04/2024
/*/
//-----------------------------------------------
Method atualizaCarga(pJsonData) Class PCLSFUSION 
  self:cBody := '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
  self:cBody += '   xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"'
  self:cBody += '   xmlns:urn="urn:myInputNamespace">'
  self:cBody += ' <soapenv:Header/>'
  self:cBody += '  <soapenv:Body>'
  self:cBody += '    <urn:atualizaCarga soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'
  self:cBody += '      <login xsi:type="xsd:string">' + self:cLogin + '</login>'
  self:cBody += '      <password xsi:type="xsd:string">' + self:cPassword + '</password>'
  self:cBody += '      <jsonData xsi:type="xsd:string">' + pJsonData + '</jsonData>'
  self:cBody += '    </urn:atualizaCarga>'
  self:cBody += ' </soapenv:Body>'
  self:cBody += '</soapenv:Envelope>'

  MemoWrite("C:\Temp\AtualizaCarga.xml",self:cBody)

Return
//------------------------------------------------------------------------------
/*/{protheusDoc.marcadores_ocultos} PCLSFUSION
  Montar a requisição e Enviar para o FUSION as
  alterações da carga.

  @author Anderson Almeida (TOTVS NE)
  @since 30/06/2021
  01/11/2023 - Valida se o pedido pode ou não ser enviado (Elvis Siqueira)
/*/
//------------------------------------------------------------------------------
Method AltCarga(pForma,pPedido,pCarga) Class PCLSFUSION 
  Local aRet      := {}
  Local nId       := 0
  Local cForma    := pForma
  Local aPedido   := pPedido
  Local lNumCarga := pCarga
  //Local lEnvia    := .T. //Valida o envio do Pedido de Venda ao Fusion

  For nId := 1 To Len(aPedido)
      dbSelectArea("SC5")
      SC5->(dbSetOrder(1))

      If SC5->(dbSeek(FWxFilial("SC5") + aPedido[nId]))
        
        /*
        lEnvia := u_ValidEnv()

        If !lEnvia
          Loop
        EndIF 
        */

        // --- Parametro: 1 - Pedido Venda
        //                2 - Sequencial do Pedido
        //                3 - Validar pelo SC5 = .T. ou SC9 = .F.
        //                4 - Excluído = .T. 
        // ------------------------------------------------------
         aRet := self:LerPedidoVenda(SC5->C5_NUM,Val(SC5->C5_XSEQFUS),.F.,.F.)

         If ! aRet[01]
            ApMsgInfo(aRet[02],"ATENÇÃO - Integração Fusion")
          else
            self:aRegistro := aRet[04]                      // Registro do Pedido de Venda
           
           //@Parâmetro:  pStatus - '1' = Aprovado
           //                       'B' = Bloqueio Financeiro
           //                       'C' = Bloqueio Comercial
           //                       '9' = Cancelado
           //             pForma  - 'S' = Sim forma carga
           //                       'N' = Não forma carga 
           //             lCarga  - .T. = Número da carga
           //                       .F. = Sem número da carga 
           // --------------------------------------------------------------------
            self:saveEntregaServico("1", cForma, lNumCarga)

              aRet := self:Enviar("saveEntregaServico") // Enviar para FUSION

            If !aRet[01]
               ApMsgAlert(aRet[02],"ATENÇÃO - Integração Fusion")  
            EndIf
         EndIf   
      EndIf  
  Next
Return   

//-------------------------------------------------
/*/{protheusDoc.marcadores_ocultos} PCLSFUSION
  Objeto Enviar
     Consumir as API's do FUSION (SOAP)

  @parámetro pSoap = Corpo da requisição
             pMetodo = Metodo da requisção

  @author  Anderson Almeida (TOTVS NE)
  @since 05/04/2021	
/*/
//-------------------------------------------------
Method Enviar(pMetodo) Class PCLSFUSION
  Local aRet     := {.T.,""}
  Local cURLFUS  := SuperGetMv("FF_XFUSION",.F.,"")
  Local cEnvSoap := self:cBody
  Local cMetodo  := pMetodo
  Local cResult  := ""
  Local cRetJson := Nil
  Local oJson    := JsonObject():new()
  Local oXML     := TXmlManager():New()
  Local oWsdl    := TWSDLManager():New()

 // -- Acessar WebService (Soap) 
 // ----------------------------
  oWsdl:nTimeout     := 120
  oWsdl:lSSLInsecure := .T.
 
  aRet[01] := oWsdl:ParseURL(cURLFUS)

  If ! aRet[01]
     aRet[02] := "FUSION está fora do ar - " + cURLFUS + ", Erro - " + oWsdl:cError

     Return aRet  
  EndIf

  aRet[01] := oWsdl:SetOperation(cMetodo)

  If ! aRet[01]
     aRet[02] := "Erro (Metodo - " + cMetodo + "): " + oWsdl:cError
 
     Return aRet 
  EndIf

  aRet[01] := oWsdl:SendSoapMsg(cEnvSoap)

  If aRet[01]
     cResult := oWsdl:GetSoapResponse()

     If ! oXML:Parse( cResult )
        aRet[01] := .F.
        aRet[02] := oXML:Error()
      else
        oXML:XPathRegisterNs("ns", "http://schemas.xmlsoap.org/soap/encoding/")

        If ! Empty(oXML:cText)
           cRetJson := oJson:FromJson(oXML:cText)

           If ValType(retJson) == "U"
              Do Case
                 Case ValType(oJson["success"]) == "A"
                      If Len(oJson["success"]) > 0 
                         aRet[01] := .T.
                         aRet[02] := oXML:cText
                      EndIf

                 Case ValType(oJson["errors"]) == "A"
                      If Len(oJson["errors"]) > 0
                         aRet[01] := .F.
                         aRet[02] := oXML:cText
                      EndIf

                 Case cMetodo == "getIntErpFilial"
                      cRetJson := oJson:FromJson('{"response":' + oXML:cText + '}')

                      If ValType(retJson) == "U" .and. ValType(oJson["response"]) == "A"
                         self:oParseJSON := oJson["response"]
                         aRet[02] := oXML:cText
                      EndIf
          
                 Case cMetodo <> "detalheCarga" .and. cMetodo <> "getIntErpFilial"
                      aRet[01] := .F.
                      aRet[02] := oXML:cText
              EndCase
           else
              If cMetodo == "setIntErp"
                 If AllTrim(oXML:cText) <> "OK"
                    aRet[01] := .F.
                    aRet[02] := oXML:cText
                  else
                    aRet[02] := oXML:cText
                 EndIf
               else
                 aRet[01] := .F.
                 aRet[02] := oXML:cText
              EndIf
           EndIf
        EndIf 
     EndIf
   else 
     aRet[02] := AllTrim(oWsdl:GetSoapResponse())
  EndIf 

 // -- Gravar o Log de Processamento
 // --------------------------------
  Reclock("Z01",.T.)
    Replace Z01->Z01_FILIAL with FWxFilial("Z01")
    Replace Z01->Z01_ID     with GetSX8Num("Z01","Z01_ID")
    Replace Z01->Z01_FILORI with cFilAnt
    Replace Z01->Z01_DATA   with Date()
    Replace Z01->Z01_HORA   with Time()
    Replace Z01->Z01_ROTINA with "PCLSFUSION"
    Replace Z01->Z01_METODO with cMetodo
    Replace Z01->Z01_OPERAC with 4
    Replace Z01->Z01_DSCOPE with "Envio e Retorno (Integração com Fusion)"
    Replace Z01->Z01_MSGRET with aRet[02]
    Replace Z01->Z01_STATUS with IIf(aRet[01],"S","E")
    Replace Z01->Z01_JSON   with cEnvSoap
  Z01->(MsUnlock())

  ConfirmSX8()
 // ------------------------------
Return aRet
