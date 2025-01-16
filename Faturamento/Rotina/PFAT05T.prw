#Include "PROTHEUS.ch"
#Include "TOTVS.ch"
#Include "TOPCONN.ch"
#Include "TBICONN.ch"
#Include 'FWMVCDef.ch'

// ----------------------------------------------
/*/{protheusDoc.marcadores_ocultos} PFAT05T

  Tela para integração do PROTHEUS x FUSION

  @author Elvis Siqueira (TOTVS)
  Retorno
  @historia
  16/01/2025 - Desenvolvimento da Rotina.
/*/
// -----------------------------------------------
User Function PFAT05T()
    Local aArea  := FWGetArea()
    Local aButtons  :=  {;
                            {.F.,Nil},;         // Copiar
                            {.F.,Nil},;         // Recortar
                            {.F.,Nil},;         // Colar
                            {.F.,Nil},;         // Calculadora
                            {.F.,Nil},;         // Spool
                            {.F.,Nil},;         // Imprimir
                            {.F.,Nil},;         // Confirmar
                            {.T.,"Fechar"},;    // Cancelar
                            {.F.,Nil},;         // WalkTrhough
                            {.F.,Nil},;         // Ambiente
                            {.F.,Nil},;         // Mashup
                            {.F.,Nil},;         // Help
                            {.F.,Nil},;         // Formulário HTML
                            {.F.,Nil};          // ECM
                        }

    Private oTabTMP1 := FWTemporaryTable():New("TMP1")
    Private oTabTMP2 := FWTemporaryTable():New("TMP2")
    Private aFields1 := {}
    Private aFields2 := {}

    aAdd(aFields1, {"T1_CODFIL","C",6 ,0,"Cod. Filial" ,"",""   })
    aAdd(aFields1, {"T1_DESCFI","C",40,0,"Desc. Filial","",""   })
    aAdd(aFields1, {"T1_DATA"  ,"D",8 ,0,"Data"        ,"",""   })
    aAdd(aFields1, {"T1_QTDPED","N",16,4,"Qtd. Pedidos","",""   })
    aAdd(aFields1, {"T1_QTDITE","N",16,4,"Total Itens" ,PesqPict( "SC9", "C9_QTDLIB"),""})
    aAdd(aFields1, {"T1_VALOR" ,"N",16,4,"Valor Total" ,PesqPict( "SC9", "C9_PRCVEN"),""})
    aAdd(aFields1, {"T1_PESO"  ,"N",16,4,"Peso Total"  ,PesqPict( "SB1", "B1_PESO"),""  })
    
    aAdd(aFields2, {"T2_LEGEND" ,"C",50,0,"Status"          ,'@BMP', "" })
    aAdd(aFields2, {"T2_MARK"   ,"L",1 ,0,"Selecionar"      ,"",""      })
    aAdd(aFields2, {"T2_FILIAL" ,"C",6 ,0,"Filial"          ,"",""      })
    aAdd(aFields2, {"T2_NUM"    ,"C",6 ,0,"Pedido"          ,"",""      })
    aAdd(aFields2, {"T2_EMISSAO","D",8 ,0,"Emissao"         ,"",""      })
    aAdd(aFields2, {"T2_SUGENT" ,"D",8 ,0,"Entrega"         ,"",""      })
    aAdd(aFields2, {"T2_QTDPROD","N",16,4,"Qtd. Pedido"     ,PesqPict( "SC9", "C9_QTDLIB"), ""})
    aAdd(aFields2, {"T2_QTDLIB" ,"N",16,4,"Qtd. Liberada"   ,PesqPict( "SC9", "C9_QTDLIB"), ""})
    aAdd(aFields2, {"T2_BAIRRO" ,"C",40,0,"Bairro"          ,"",""      })
    aAdd(aFields2, {"T2_DESCMUN","C",30,0,"Cidade"          ,"",""      })
    aAdd(aFields2, {"T2_UFORIG" ,"C",2 ,0,"Estado"          ,"",""      })
    aAdd(aFields2, {"T2_VALOR"  ,"N",16,4,"Valor"           ,PesqPict( "SC9", "C9_PRCVEN"), ""})
    aAdd(aFields2, {"T2_PESO"   ,"N",16,4,"Peso"            ,PesqPict( "SB1", "B1_PESO")  , ""})
    aAdd(aFields2, {"T2_CLIENTE","C",12,0,"Cod. Cliente"    ,"",""      })
    aAdd(aFields2, {"T2_LOJACLI","C",4 ,0,"Loja Cliente"    ,"",""      })
    aAdd(aFields2, {"T2_NOMECLI","C",40,0,"Nome"            ,"",""      })
    aAdd(aFields2, {"T2_VEND1"  ,"C",6 ,0,"Cod. Vendedor"   ,"",""      })
    aAdd(aFields2, {"T2_NONVEND","C",40,0,"Nome Vendedor"   ,"",""      })

    oTabTMP1:SetFields(aFields1)
    oTabTMP1:Create()

    oTabTMP2:SetFields(aFields2)
    oTabTMP2:AddIndex("1", {"T2_NUM"} )
    oTabTMP2:Create()

    IF Pergunte("TELAFUSION", .T.)
        FWExecView("Integração Fusion","PFAT05T",MODEL_OPERATION_INSERT,,{|| .T.},,,aButtons,{|| fMyCancel()})
    EndIf 

    oTabTMP1:Delete()
    oTabTMP2:Delete()

    FWRestArea(aArea)

Return

/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Desc:  Criação do modelo de dados MVC                               |
 | Obs.:  /                                                            |
 *--------------------------------------------------------------------*/
Static Function ModelDef()
    Local oModel as object
    Local oStrTMP1 := fnM01TMP("1")
    Local oStrTMP2  := fnM01TMP("2")

    oModel := MPFormModel():New('PFAT05TM',/*bPre*/,/*bPost*/,/*bCommit*/,/*bCancel*/)
    oModel:AddFields('TABTMP1',/*cOwner*/,oStrTMP1/*bPre*/,/*bPos*/,/*bLoad*/)
    oModel:AddGrid('TABTMP2','TABTMP1',oStrTMP2,/*bLinePre*/,/*bLinePost*/,/*bPre - Grid Inteiro*/,/*bPos - Grid Inteiro*/,/*bLoad - Carga do modelo manualmente*/)
    oModel:SetPrimaryKey({})

Return oModel

//-----------------------------------------
/*/ fnM01TMP
  Estrutura (Model)							  
/*/
//-----------------------------------------
Static Function fnM01TMP(cTab)
    Local oStruct := FWFormModelStruct():New()
    Local cField := "aFields"+cTab
    Local nId  

    oStruct:AddTable(cTab,{},"Tabela "+cTab)

    For nId := 1 To Len(&(cField))
        oStruct:AddField(&(cField)[nId][5]; 
                        ,&(cField)[nId][5]; 
                        ,&(cField)[nId][1]; 
                        ,&(cField)[nId][2];
                        ,&(cField)[nId][3];
                        ,&(cField)[nId][4];
                        ,Nil,Nil,{},.F.,,.F.,.F.,.F.)
    Next nId

Return oStruct

/*---------------------------------------------------------------------*
 | Func:  ViewDef                                                      |
 | Desc:  Criação da visão MVC                                         |
 | Obs.:  /                                                            |
 *--------------------------------------------------------------------*/
 
Static Function ViewDef()
    Local oView as object
    Local oModel as object
    Local oStrTMP1 := fnV01TMP("1")
    Local oStrTMP2 := fnV01TMP("2")

    oModel := FWLoadModel("PFAT05T")

    oView := FwFormView():New()
    oView:SetModel(oModel)
    oView:SetProgressBar(.T.)
    oView:AddField("VIEW_TABTMP1", oStrTMP1 , "TABTMP1")
    oView:AddGrid("VIEW_TABTMP2" , oStrTMP2 , "TABTMP2")

    oView:CreateHorizontalBox("CABEC", 20 )
    oView:CreateHorizontalBox("GRID" , 80 )

    oView:SetOwnerView('VIEW_TABTMP1','CABEC')
    oView:SetOwnerView('VIEW_TABTMP2','GRID')

    oView:SetAfterViewActivate({|| ViewActv()})

    // Acrescenta um objeto externo ao View do MVC
    //oView:AddOtherObject("VIEW_TABTMP2", {|oPanel| tBtnAll(oPanel)})

    oView:AddUserButton( 'Marcar/Desmarcar', 'MAGIC_BMP',;
                        {|| fSelectAll() },;
                         /*cToolTip  | Comentário do botão*/,;
                         /*nShortCut | Codigo da Tecla para criação de Tecla de Atalho*/,;
                         /*aOptions  | */,;
                         /*lShowBar */ .T.)

    oView:AddUserButton( 'Enviar P/ Fusion', 'MAGIC_BMP',;
                        {|| fProssFus() },;
                         /*cToolTip  | Comentário do botão*/,;
                         /*nShortCut | Codigo da Tecla para criação de Tecla de Atalho*/,;
                         /*aOptions  | */,;
                         /*lShowBar */ .T.)

    oView:SetCloseOnOk({||.T.})

    oView:EnableTitleView('VIEW_TABTMP1','Totais')
    oView:EnableTitleView('VIEW_TABTMP2','Pedidos de Venda')

    oView:SetViewProperty("VIEW_TABTMP2", "GRIDSEEK"  , {.T.})
    oView:SetViewProperty("VIEW_TABTMP2", "GRIDFILTER", {.T.})

Return oView

//-------------------------------------------------------------------
/*/ Função fnV01TMP()
  Estrutura (View)	
/*/
//-------------------------------------------------------------------
Static Function fnV01TMP(cTab)
    Local oViewTMP := FWFormViewStruct():New() 
    Local cField := "aFields"+cTab
    Local cCampBlq := "T1_CODFIL/T1_DESCFI/T1_DATA/T1_QTDPED/T1_QTDITE/T1_VALOR/T1_PESO/T2_LEGEND"
    Local lBloq := .T.
    Local nId

    For nId := 1 To Len(&(cField))
        
        lBloq := IIF(&(cField)[nId][1] $ (cCampBlq),.F.,.T.)
        
        oViewTMP:AddField(&(cField)[nId][1],;   // 01 = Nome do Campo
                        StrZero(nId,2),;        // 02 = Ordem
                        &(cField)[nId][5],;     // 03 = Título do campo
                        &(cField)[nId][5],;     // 04 = Descrição do campo
                        Nil,;                   // 05 = Array com Help
                        &(cField)[nId][2],;     // 06 = Tipo do campo
                        &(cField)[nId][6],;     // 07 = Picture
                        Nil,;                   // 08 = Bloco de PictTre Var
                        &(cField)[nId][7],;     // 09 = Consulta F3
                        lBloq,;                 // 10 = Indica se o campo é alterável
                        Nil,;                   // 11 = Pasta do Campo
                        Nil,;                   // 12 = Agrupamnento do campo
                        Nil,;                   // 13 = Lista de valores permitido do campo (Combo)
                        Nil,;                   // 14 = Tamanho máximo da opção do combo
                        Nil,;                   // 15 = Inicializador de Browse
                        .F.,;                   // 16 = Indica se o campo é virtual (.T. ou .F.)
                        Nil,;                   // 17 = Picture Variavel
                        Nil)                    // 18 = Indica pulo de linha após o campo (.T. ou .F.)
    Next nId

Return oViewTMP

/*---------------------------------------------------------------------*
 | Func:  ViewActv                                                     |
 | Desc:  Popula as tabelas TMP1 (Cabeçalho) e TMP2 (Grid)             |
 | Obs.:  /                                                            |
 *--------------------------------------------------------------------*/
Static Function ViewActv()
    Local oModel    := FWModelActive()
    Local oView     := FWViewActive()
    Local oStrTMP1  := oModel:GetModel("TABTMP1")
    Local oStrTMP2  := oModel:GetModel("TABTMP2")
    Local cQry      := ""
    Local nItensTot := 0
    Local nVlrTotal := 0
    Local nPesoTot  := 0
    Local nQtdLib   := 0
    Local nPesoLib  := 0
    Local nLinWhile := 0

    Private __cAlias  := "TMP1"+FWTimeStamp(1)

    cQry := " SELECT DISTINCT SC5.C5_FILIAL, SC5.C5_NUM, SC5.C5_EMISSAO, SC5.C5_SUGENT, SUM(SC6.C6_QTDVEN) AS QTDVEN, "
    cQry += " SUM(SC6.C6_VALOR) AS VALOR, SC5.C5_CLIENTE, SC5.C5_LOJACLI, SA1.A1_NOME AS NOMECLI, SC5.C5_VEND1, SC5.C5_DESCMUN, SC5.C5_UFORIG, SC5.R_E_C_N_O_  "
    cQry += " FROM "+ RetSqlName("SC5") +" SC5 "
    cQry += " INNER JOIN "+ RetSqlName("SC6") +" SC6 ON SC6.C6_NUM = SC5.C5_NUM "
    cQry += " INNER JOIN "+ RetSqlName("SA1") +" SA1 ON SA1.A1_COD = SC5.C5_CLIENTE AND SA1.A1_LOJA = SC5.C5_LOJACLI "
    cQry += " WHERE SC5.D_E_L_E_T_ <> '*' "
    cQry += "   AND SC6.D_E_L_E_T_ <> '*' "
    cQry += "   AND SA1.D_E_L_E_T_ <> '*' "
    cQry += "   AND	SC5.C5_FILIAL  = '"+MV_PAR01+"' "
    cQry += "   AND	SC6.C6_FILIAL  = SC5.C5_FILIAL "
    cQry += "   AND	SA1.A1_FILIAL  = '" + xFilial("SA1") + "' "
    cQry += "   AND SC5.C5_NUM BETWEEN '" + MV_PAR02 + "' AND '" +  MV_PAR03 + "' "
    If !Empty(MV_PAR04) .AND. !Empty(MV_PAR05)
    cQry += "   AND	SC5.C5_CLIENTE = '" + MV_PAR04 + "' "
    cQry += "   AND	SC5.C5_LOJACLI = '" + MV_PAR05 + "' "
    EndIF
    cQry += "   AND 	SC5.C5_EMISSAO BETWEEN '" +  DToS(MV_PAR06) + "' AND '" +  DToS(MV_PAR07) + "' "
    If !Empty(MV_PAR08) .AND. !Empty(MV_PAR09)
    cQry += "   AND 	SC5.C5_SUGENT  BETWEEN '" +  DToS(MV_PAR08) + "' AND '" +  DToS(MV_PAR09) + "' "  
    EndIF 
    If !Empty(MV_PAR10)
    cQry += "   AND	SC5.C5_VEND1 = '" + MV_PAR10 + "' "
    EndIF
    If MV_PAR11 == 1
    cQry += "   AND	SC5.C5_XSTATUS = '' "    
    EndIF
    If !Empty(MV_PAR13)
    cQry += "   AND	SC5.C5_DESCMUN LIKE '%" + Alltrim(MV_PAR13) + "%' "
    EndIF
    If !Empty(MV_PAR14)
    cQry += "   AND	SC5.C5_UFORIG = '" + MV_PAR14 + "' "
    EndIF
    cQry += "   AND	SC5.C5_XCARGA = '' "
    cQry += "   AND	SC5.C5_TPCARGA = '1' "
    cQry += " GROUP BY SC5.C5_FILIAL, SC5.C5_NUM, SC5.C5_EMISSAO, SC5.C5_SUGENT, SC5.C5_CLIENTE, SC5.C5_LOJACLI, SA1.A1_NOME, SC5.C5_VEND1, SC5.C5_DESCMUN, SC5.C5_UFORIG, SC5.R_E_C_N_O_ "
    cQry += " ORDER BY SC5.C5_NUM "
    cQry := ChangeQuery(cQry)
    IF Select(__cAlias) <> 0
        (__cAlias)->(DbCloseArea())
    EndIf
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),__cAlias,.T.,.T.)

    While (__cAlias)->(!EOF())

        nLinWhile++
        If nLinWhile > 1
            oStrTMP2:AddLine()
            oStrTMP2:GoLine(nLinWhile)
        EndIF 
        
        oStrTMP2:LoadValue("T2_LEGEND" , "BR_VIOLETA"                   )
        oStrTMP2:LoadValue("T2_FILIAL" , (__cAlias)->C5_FILIAL          )
        oStrTMP2:LoadValue("T2_NUM"    , (__cAlias)->C5_NUM             )
        oStrTMP2:LoadValue("T2_EMISSAO", SToD((__cAlias)->C5_EMISSAO)   )
        oStrTMP2:LoadValue("T2_SUGENT" , STOD((__cAlias)->C5_SUGENT )   )
        oStrTMP2:LoadValue("T2_DESCMUN", Alltrim((__cAlias)->C5_DESCMUN))
        oStrTMP2:LoadValue("T2_UFORIG" , Alltrim((__cAlias)->C5_UFORIG) )
        oStrTMP2:LoadValue("T2_CLIENTE", (__cAlias)->C5_CLIENTE         )
        oStrTMP2:LoadValue("T2_LOJACLI", (__cAlias)->C5_LOJACLI         )
        oStrTMP2:LoadValue("T2_NOMECLI", Pad((__cAlias)->NOMECLI,40)    )
        oStrTMP2:LoadValue("T2_VEND1"  , (__cAlias)->C5_VEND1           )
        oStrTMP2:LoadValue("T2_NONVEND", Posicione("SA3",1,xFilial("SA3")+(__cAlias)->C5_VEND1, "A3_NOME")  )
        oStrTMP2:LoadValue("T2_QTDPROD", (__cAlias)->QTDVEN             )
        oStrTMP2:LoadValue("T2_VALOR"  , (__cAlias)->VALOR              )
        oStrTMP2:LoadValue("T2_QTDLIB" , nQtdLib  )
        oStrTMP2:LoadValue("T2_PESO"   , nPesoLib )
        nItensTot += (__cAlias)->QTDVEN
        nVlrTotal += (__cAlias)->VALOR
        nPesoTot  += nPesoLib
        
        oView:Refresh("VIEW_TABTMP2")

        (__cAlias)->(DBSkip())
    EndDo

    oStrTMP1:LoadValue("T1_CODFIL", MV_PAR01 )
    oStrTMP1:LoadValue("T1_DESCFI", Pad(FWFilialName(cEmpAnt, MV_PAR01, 1),40) )
    oStrTMP1:LoadValue("T1_DATA"  , dDataBase )
    oStrTMP1:LoadValue("T1_QTDPED", nLinWhile )
    oStrTMP1:LoadValue("T1_QTDITE", nItensTot )
    oStrTMP1:LoadValue("T1_VALOR" , nVlrTotal )
    oStrTMP1:LoadValue("T1_PESO"  , nPesoTot  )

    oView:Refresh("VIEW_TABTMP1")

    oStrTMP2:GoLine(1)
    oView:Refresh("VIEW_TABTMP2")

    oView:SetNoDeleteLine('VIEW_TABTMP2')
    oView:SetNoInsertLine('VIEW_TABTMP2')

Return

/*---------------------------------------------------------------------*
 | Func:  tBtnAll                                                      |
 | Desc:  Botão para selecionar todos os registros do GRID             |
 | Obs.:  /                                                            |
 *--------------------------------------------------------------------*/
Static Function tBtnAll(oPanel)
    Local cFont := "Arial"
    Local oFontBtn := TFont():New(cFont,,-14,,.T.)
    
    oBtnT1:= TButton():New( 100, 002, "Marcar/Desmarcar" ,oPanel,{||fSelectAll()}, 70,15,,oFontBtn,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnT3:= TButton():New( 100, 170, "Enviar Fusion"    ,oPanel,{||fEnvFusion()}, 60,15,,oFontBtn,.F.,.T.,.F.,,.F.,,,.F. )

Return

/*---------------------------------------------------------------------*
 | Func:  fSelectAll                                                   |
 | Desc:  Marca e Desmarca todos os registros do GRID                  |
 | Obs.:  /                                                            |
 *--------------------------------------------------------------------*/
Static Function fSelectAll()
    Local oModel := FWModelActive()
    Local oView := FWViewActive()
    Local oStrTMP2 := oModel:GetModel("TABTMP2")
    Local nY

    For nY := 1 To oStrTMP2:Length()
        oStrTMP2:GoLine(nY)
        If !oStrTMP2:IsDeleted()
            If oStrTMP2:GetValue("T2_MARK")
                oStrTMP2:SetValue("T2_MARK", .F.)
            Else
                oStrTMP2:SetValue("T2_MARK", .T.)
            EndIF
        EndIf
    Next nY

    oStrTMP2:GoLine(1)
    oView:Refresh("VIEW_TABTMP2")

Return

/*---------------------------------------------------------------------*
 | Func:  fProssFus                                                    |
 | Desc:  Prepara para enviar os Pedidos de Vendas selecionados        |  
 |        no GRID ao Fusion                                            |
 | Obs.:  /                                                            |
 *--------------------------------------------------------------------*/
Static Function fProssFus()
    
    Processa({|| fEnvFusion()}, "Enviando...")

Return 
/*---------------------------------------------------------------------*
 | Func:  fEnvFusion                                                   |
 | Desc:  Envia os Pedidos de Vendas selecionados no GRID ao Fusion    |
 | Obs.:  /                                                            |
 *--------------------------------------------------------------------*/
Static Function fEnvFusion()
    Local oModel   := FWModelActive()
    Local oView    := FWViewActive()
    Local oStrTMP2 := oModel:GetModel("TABTMP2")
    Local lEnv := 0
    Local nY

    Private cNumC5 := ""
    Private cValor := ""
    Private cPeso  := ""

    ProcRegua(oStrTMP2:Length())

    For nY := 1 To oStrTMP2:Length()
        oStrTMP2:GoLine(nY)
        If !oStrTMP2:IsDeleted()
            If oStrTMP2:GetValue("T2_MARK")
                IncProc("Enviando pedido " + cValToChar(nY) + " de " + cValToChar(oStrTMP2:Length()) + "...")
                
                cNumC5 := oStrTMP2:GetValue("T2_NUM")
                cValor := AllTrim(AllToChar(oStrTMP2:GetValue("T2_VALOR"),"@E 999,999,999.99"))
                cPeso  := AllTrim(AllToChar(oStrTMP2:GetValue("T2_PESO"),"@E 999,999,999.99"))
                
                dbSelectArea("SC5")
                SC5->(MSSeek(xFilial("SC5")+cNumC5))
                
                lerPedido()
                
                lEnv++
            EndIF
        EndIf
    Next nY

    oStrTMP2:GoLine(1)
    oView:Refresh("VIEW_TABTMP2")

    If lEnv > 0
        FWAlertSuccess("Finalizado o envio ao Fusion", "Envio Fusion")
    Else
        FWAlertWarning("Nenhum Pedido de Venda marcado!", "Envio Fusion")
    EndIF 

Return

/*-----------------------------------------------------------------------*
 | Func:  fMyCance                                                       |
 | Desc:  Função para modificar o lModify e fechar a tela sem            |
 |        apresentar a mensagem "Há alterações não salvas no formulário" |
 | Obs.:  /                                                              |
 *----------------------------------------------------------------------*/
Static Function fMyCancel()
    Local oModel := FWModelActive()

    If (!Empty(oModel))
        oModel:lModify := .F.
    EndIf
    
Return .T.

//----------------------------------------------------------------------
/*/ Function PCLSFUSION  
    Ler Pedido de Venda

    @parámetro  pPedido - Número do Pedido de Venda.
                pSeq    - Sequencial do pedido. Para o primeiro é "0"
                          e não manda para a FUSION o sequencial.
                pBloq   - .T. precisa validar se o pedido está bloqueado.
                          .F. precisa validar se o pedido está liberado.
                pNF     - Número da Nota Fiscal de saída.
                pSerie  - Número da Serie da Nota Fiscal de saída.  
             
  @author Elvis Siqueira (TOTVS)
  @since  09/01/2025
/*/
//----------------------------------------------------------------------

Static Function lerPedido()
    Local cLogin    := SuperGetMv("FF_XFUSUSE",.F.,"")
    Local cPassword := SuperGetMv("FF_XFUSPWD",.F.,"")
    Local cBody     := ""
    Local cDsRegiao := ""
    Local cDsRota   := ""
    Local cQry      := ""
    Local QPSQ      := GetNextAlias()
    Local nTotQry   := 0
    Local nPosQry   := 0

    cQuery := "Select SC9.C9_PRODUTO as PRODUTO, SC9.C9_QTDLIB as QTDE, SC9.C9_PRCVEN as PRCVEN,"
    cQuery += "       SC9.C9_CARGA as CARGA, SB1.B1_DESC, SB1.B1_UM, SB1.B1_POSIPI, SB1.B1_PESO,"
    cQuery += "       SB5.B5_ALTURLC, SB5.B5_COMPRLC, SB5.B5_LARGLC, SC9.C9_NFISCAL,"
    cQuery += "       Case when ((SC9.C9_BLCRED <> '10' and SC9.C9_BLCRED <> '') or"
    cQuery += "                  (SC9.C9_BLEST <> '10' and SC9.C9_BLEST <> ''))"
    cQuery += "             Then 'B' else 'L' end BLOQ, SC9.R_E_C_N_O_ as RECNO"
    cQuery += "  from " + RetSqlName("SC9") + " SC9, " + RetSqlName("SB1") + " SB1, " + RetSqlName("SB5") + " SB5"
    cQuery += "   where SC9.D_E_L_E_T_ <> '*'"
    cQuery += "     and SC9.C9_FILIAL  = '" + xFilial("SC5") + "'"
    cQuery += "     and SC9.C9_PEDIDO  = '" + cNumC5 + "'"
    cQuery += "     and SC9.C9_NFISCAL = ''"
    cQuery += "     and SC9.C9_SERIENF = ''"
    cQuery += "     and SB1.D_E_L_E_T_ <> '*'"
    cQuery += "     and SB1.B1_FILIAL  = '" + xFilial("SB1") + "'"
    cQuery += "     and SB1.B1_COD     = SC9.C9_PRODUTO" 
    cQuery += "     and SB5.D_E_L_E_T_ <> '*'"
    cQuery += "     and SB5.B5_FILIAL  = '" + xFilial("SB5") + "'"
    cQuery += "     and SB5.B5_COD     = SB1.B1_COD"
    cQuery := ChangeQuery(cQuery)
    IF Select(QPSQ) <> 0
        (QPSQ)->(DbCloseArea())
    EndIf
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),QPSQ,.T.,.T.)
    Count To nTotQry
    (QPSQ)->(DBGoTOP())

    cDsRegiao := AllTrim(Posicione("SX5",1,FWxFilial("SX5") + "A2" + (QPSQ)->C5_XREGIAO,"X5_DESCRI"))
    cDsRota   := AllTrim(Posicione("Z02",1,FWxFilial("Z02") + (QPSQ)->A1_XROTA,"Z02_DESCRI"))

    cBody := '<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" '
    cBody += ' xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"'
    cBody += ' xmlns:urn="urn:myInputNamespace">'
    cBody += ' <soapenv:Header/>'
    cBody += ' <soapenv:Body>'
    cBody += '   <urn:saveEntregaServico soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'
    cBody += '     <login xsi:type="xsd:string">' + cLogin + '</login>'
    cBody += '     <senha xsi:type="xsd:string">' + cPassword + '</senha>'
    cBody += '     <array_dados><![CDATA['
    cBody += '        ['  
    cBody += '         {'
    cBody += '          "nf": "",'
    cBody += '          "serie": "",'
    cBody += '          "tipo": "",'
    cBody += '          "ent_ou_serv": "Entrega",'
    cBody += '          "pedido_erp": "' + cNumC5 + '",'
    cBody += '          "forma_pgto": "' + Alltrim(Posicione("SE4",1,FWxFilial("SE4")+(QPSQ)->C5_CONDPAG,"E4_DESCRI")) + '",'
    cBody += '          "status": "N",'
    cBody += '          "obs": "",'
    cBody += '          "num_ped_conf": "' + cNumC5 + '",'
    cBody += '          "carga": "",'
    cBody += '          "cubagem": "0.000001",'
    cBody += '          "podeformarcarga": "S",'
    cBody += '          "valor": "'+cValor+'",'
    cBody += '          "peso": "'+cPeso+'",'
    cBody += '          "valor_st": "0",'
    cBody += '          "empresa_fat": "' + cFilAnt + '",'
    cBody += '          "empresa_log": "' + cFilAnt + '",'
    cBody += '          "empresa_digit": "' + cFilAnt + '",'
    cBody += '          "pedido_orig": "' + cNumC5 + '",'
    cBody += '          "dt_list_nf": "' + SubStr(FWTimeStamp(3,SC5->C5_EMISSAO),"T"," ") + '",'
    cBody += '          "data_alt": "' + SubStr(FWTimeStamp(3,SC5->C5_EMISSAO),"T"," ") + '",'
    cBody += '          "nf_cod_rota_erp": "",'
    cBody += '          "nf_descricao_rota": "",'
    cBody += '          "descr_cliente": "' + FwNoAccent(AllTrim((QPSQ)->A1_NREDUZ)) + '",'
    cBody += '          "razao_cliente": "' + FwNoAccent(AllTrim((QPSQ)->A1_NOME)) + '",'
    cBody += '          "cnpj_cliente": "' + AllTrim((QPSQ)->A1_CGC) + '",'
    cBody += '          "end_cliente": "' + FwNoAccent(Alltrim(IIF(!Empty((QPSQ)->A1_ENDENT),(QPSQ)->A1_ENDENT,(QPSQ)->A1_END))) + '",'
    cBody += '          "bairro_cliente": "' + FwNoAccent(Alltrim(IIF(!Empty((QPSQ)->A1_BAIRROE),(QPSQ)->A1_BAIRROE,(QPSQ)->A1_BAIRRO))) + '",'
    cBody += '          "num_end_cliente": "' + AllTrim((QPSQ)->A1_XNUMEND) + '",'
    cBody += '          "uf_cliente": "' + IIF(!Empty((QPSQ)->A1_ESTE),(QPSQ)->A1_ESTE,(QPSQ)->A1_EST) + '",'
    cBody += '          "cidade_cliente": "' + FwNoAccent(Alltrim(IIF(!Empty((QPSQ)->A1_MUNE),(QPSQ)->A1_MUNE,(QPSQ)->A1_MUN))) + '",'
    cBody += '          "cep_cliente": "' + IIF(!Empty((QPSQ)->A1_CEPE),(QPSQ)->A1_CEPE,(QPSQ)->A1_CEP) + '",'
    cBody += '          "email1_cliente": "' + FwNoAccent(AllTrim((QPSQ)->A1_EMAIL)) + '",'
    cBody += '          "email2_cliente": "",'
    cBody += '          "email3_cliente": "",'
    cBody += '          "tel1_cliente": "' + AllTrim((QPSQ)->A1_TEL) + '",'
    cBody += '          "tel2_cliente": "",'
    cBody += '          "tel3_cliente": "",'
    cBody += '          "vlr_credito_cliente": "0",'
    cBody += '          "data_cadastro_cliente": "' + SubStr(FWTimeStamp(3,SC5->C5_EMISSAO),"T"," ") + '",'
    cBody += '          "saldo_disp_cliente": "0",'
    cBody += '          "vlr_tits_vencido_cliente": "0",'
    cBody += '          "vlr_tits_vencer_cliente": "0",'
    cBody += '          "status_cred_cliente": "C",'
    cBody += '          "codigo_cliente": "' + AllTrim((QPSQ)->A1_COD) + AllTrim((QPSQ)->A1_LOJA) + '",'
    cBody += '          "cod_segmento": "2",'
    cBody += '          "descr_segmento": "ATACADO",'
    cBody += '          "filial_padrao": "' + cFilAnt + '",'
    cBody += '          "data_ult_compra": "' + SubStr(FWTimeStamp(3,SC5->C5_EMISSAO),"T"," ") + '",'
    cBody += '          "forma_pgto_cliente": "1",'
    cBody += '          "retem_icms_cliente": "N",'
    cBody += '          "permite_retira_cliente": "N",'
    cBody += '          "rede_loja_cliente": "' + (QPSQ)->A1_LOJA + '",'
    cBody += '          "rota_cod_erp": "",'
    cBody += '          "rota_descricao": "",'
    cBody += '          "praca_cod_erp": "",'
    cBody += '          "praca_descricao": "",'
    cBody += '          "vendedor_erp": "' + FwNoAccent(Posicione("SA3",1,xFilial("SA3") + (QPSQ)->C5_VEND1,"A3_NREDUZ")) + '",'
    cBody += '          "data_pedido": "' + SubStr(FWTimeStamp(3,SC5->C5_EMISSAO),"T"," ") + '",'
    cBody += '          "codigo_endereco_alt": "",'
    cBody += '          "referencia_entrega": "",'
    cBody += '          "restricao_transp": "N",'
    cBody += '          "prioridade": "N",'
    cBody += '          "latitude": 0,'
    cBody += '          "longitude": 0,'
    cBody += '          "itens":'
    cBody += '             ['

    While (QPSQ)->(!Eof())
        
        nPosQry++
        If QPSQ->BLOQ == "L"
            cBody += '  {'
            cBody += '   "cod_produto_erp": "' + (QPSQ)->C6_PRODUTO + '",'
            cBody += '   "descricao": "' + AllTrim(FwNoAccent((QPSQ)->B1_DESC)) + '",'
            cBody += '   "unidade": "' + (QPSQ)->B1_UM + '",'
            cBody += '   "qtd": "' + AllTrim(Str((QPSQ)->C6_QTDVEN,16,2)) + '",'
            cBody += '   "peso": "",'
            cBody += '   "preco": "' + AllTrim(Str((QPSQ)->C6_PRCVEN,16,2)) + '",'
            cBody += '   "subtotal": "' + AllTrim(Str((QPSQ)->C6_VALOR,16,2)) + '",'
            cBody += '   "valor_icms_st": "",'
            cBody += '   "ncm": "' + (QPSQ)->B1_POSIPI + '",'
            cBody += '   "cst": "",'
            cBody += '   "obs_item": ""'
            cBody += '  }' + IIf(nPosQry < nTotQry,',','')
        EndIF 
    (QPSQ)->(dbSkip()) 
    End

    cBody += '         ],'
    cBody += '         "titulos": [ { } ]'
    cBody += '        }'
    cBody += '       ]'
    cBody += '      ]]>'
    cBody += '     </array_dados>'
    cBody += '   </urn:saveEntregaServico>'
    cBody += ' </soapenv:Body>'
    cBody += '</soapenv:Envelope>'
 
  (QPSQ)->(dbCloseArea())

  Enviar(cBody)

Return

//-------------------------------------------------
/*/ Funcao Enviar

  Objeto Enviar

     Consumir as API's do FUSION (SOAP)

  @parámetro pSoap = Corpo da requisição
             pMetodo = Metodo da requisção
  @author Elvis Siqueira (TOTVS)
  @since   09/01/2025	
/*/
//-------------------------------------------------
Static Function Enviar(pBody)
  Local aRet     := {.T.,""}
  Local cURLFUS  := SuperGetMv("FF_XFUSION",.F.,"")
  Local cEnvSoap := pBody
  Local cMetodo  := "saveEntregaServico"
  Local cResult  := ""
  Local cRetJson := Nil
  Local oJson    := JsonObject():new()
  Local oXML     := TXmlManager():New()
  Local oWsdl    := TWSDLManager():New()

 // -- Acessar WebService (Soap) 
 // ----------------------------
  oWsdl:nTimeout         := 180
  oWsdl:lSSLInsecure     := .T.
  oWsdl:lProcResp        := .T.
  oWsdl:bNoCheckPeerCert := .T.
  oWsdl:lUseNSPrefix     := .T.
  oWsdl:lVerbose         := .T.
 
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

     If ! oXML:Parse(cResult)
        aRet[01] := .F.
        aRet[02] := oXML:Error()
      else
        oXML:XPathRegisterNs("ns", "http://schemas.xmlsoap.org/soap/encoding/")

        If ! Empty(oXML:cText)
           cRetJson := oJson:FromJson(oXML:cText)

           If ValType(cRetJson) == "U"
              If cMetodo == "getIntErp"
                 cRetJson := oJson:FromJson('{"response":' + oXML:cText + '}')

                 If ValType(cRetJson) == "U" .and. ValType(oJson["response"]) == "A"
                    self:oParseJSON := oJson["response"]
                    aRet[02]        := oXML:cText
                 EndIf
               else
                 If ValType(oJson["erro_detalhes"]) == "A"
                    If Len(oJson["erro_detalhes"]) > 0
                       aRet[01] := .F.
                       aRet[02] := oJson["erro_detalhes"][1]["descricao"]
                    EndIf
                 EndIf

                 If ValType(oJson["errors"]) == "A"
                    If Len(oJson["errors"]) > 0
                       aRet[01] := .F.
                       aRet[02] := oJson["errors"][1]
                    EndIf
                 EndIf

                 If ValType(oJson["success"]) == "A" .and. aRet[01]
                    If Len(oJson["success"]) > 0 
                       aRet[01] := .T.
                       aRet[02] := oXML:cText
                    EndIf
                 EndIf
              EndIf
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
    Replace Z01->Z01_OPERAC with 5
    Replace Z01->Z01_DSCOPE with "Envio de Cancelamento (Integração com Fusion)"
    Replace Z01->Z01_MSGRET with aRet[02]
    Replace Z01->Z01_STATUS with IIf(aRet[01],"S","E")
    Replace Z01->Z01_JSON   with cEnvSoap
  Z01->(MsUnlock())

  ConfirmSX8()
 // --------------------------------
Return aRet
