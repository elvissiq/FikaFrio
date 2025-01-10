#Include "PROTHEUS.ch"
#Include "TOTVS.ch"
#Include "TOPCONN.ch"
#Include "TBICONN.ch"
#Include 'FWMVCDef.ch'

// ----------------------------------------------
/*/{protheusDoc.marcadores_ocultos} PFAT005

  Tela para integra��o do PROTHEUS x FUSION

  @author Elvis Siqueira (TOTVS)
  Retorno
  @historia
  09/01/2025 - Desenvolvimento da Rotina.
/*/
// -----------------------------------------------
User Function PFAT005()
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
                            {.F.,Nil},;         // Formul�rio HTML
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
    oTabTMP2:Create()

    IF Pergunte("TELAFUSION", .T.)
        FWExecView("Integra��o Fusion","PFAT005",MODEL_OPERATION_INSERT,,{|| .T.},,,aButtons,{|| fMyCancel()})
    EndIf 

    oTabTMP1:Delete()
    oTabTMP2:Delete()

    FWRestArea(aArea)

Return

/*---------------------------------------------------------------------*
 | Func:  ModelDef                                                     |
 | Desc:  Cria��o do modelo de dados MVC                               |
 | Obs.:  /                                                            |
 *--------------------------------------------------------------------*/
Static Function ModelDef()
    Local oModel as object
    Local oStrTMP1 := fnM01TMP("1")
    Local oStrTMP2  := fnM01TMP("2")

    oModel := MPFormModel():New('PFAT005M',/*bPre*/,/*bPost*/,/*bCommit*/,/*bCancel*/)
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
 | Desc:  Cria��o da vis�o MVC                                         |
 | Obs.:  /                                                            |
 *--------------------------------------------------------------------*/
 
Static Function ViewDef()
    Local oView as object
    Local oModel as object
    Local oStrTMP1 := fnV01TMP("1")
    Local oStrTMP2 := fnV01TMP("2")

    oModel := FWLoadModel("PFAT005")

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
                         /*cToolTip  | Coment�rio do bot�o*/,;
                         /*nShortCut | Codigo da Tecla para cria��o de Tecla de Atalho*/,;
                         /*aOptions  | */,;
                         /*lShowBar */ .T.)

    oView:AddUserButton( 'Enviar P/ Fusion', 'MAGIC_BMP',;
                        {|| fProssFus() },;
                         /*cToolTip  | Coment�rio do bot�o*/,;
                         /*nShortCut | Codigo da Tecla para cria��o de Tecla de Atalho*/,;
                         /*aOptions  | */,;
                         /*lShowBar */ .T.)

    oView:AddUserButton( 'Visualizar Pedido', 'MAGIC_BMP',;
                        {|| fVisualiz() },;
                         /*cToolTip  | Coment�rio do bot�o*/,;
                         /*nShortCut | Codigo da Tecla para cria��o de Tecla de Atalho*/,;
                         /*aOptions  | */,;
                         /*lShowBar */ .T.)

    oView:SetCloseOnOk({||.T.})

    oView:EnableTitleView('VIEW_TABTMP1','Totais')
    oView:EnableTitleView('VIEW_TABTMP2','Pedidos de Venda')

    oView:SetViewProperty("VIEW_TABTMP2", "GRIDSEEK"  , {.T.})
    oView:SetViewProperty("VIEW_TABTMP2", "GRIDFILTER", {.T.})

Return oView

//-------------------------------------------------------------------
/*/ Fun��o fnV01TMP()
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
                        &(cField)[nId][5],;     // 03 = T�tulo do campo
                        &(cField)[nId][5],;     // 04 = Descri��o do campo
                        Nil,;                   // 05 = Array com Help
                        &(cField)[nId][2],;     // 06 = Tipo do campo
                        &(cField)[nId][6],;     // 07 = Picture
                        Nil,;                   // 08 = Bloco de PictTre Var
                        &(cField)[nId][7],;     // 09 = Consulta F3
                        lBloq,;                 // 10 = Indica se o campo � alter�vel
                        Nil,;                   // 11 = Pasta do Campo
                        Nil,;                   // 12 = Agrupamnento do campo
                        Nil,;                   // 13 = Lista de valores permitido do campo (Combo)
                        Nil,;                   // 14 = Tamanho m�ximo da op��o do combo
                        Nil,;                   // 15 = Inicializador de Browse
                        .F.,;                   // 16 = Indica se o campo � virtual (.T. ou .F.)
                        Nil,;                   // 17 = Picture Variavel
                        Nil)                    // 18 = Indica pulo de linha ap�s o campo (.T. ou .F.)
    Next nId

Return oViewTMP

/*---------------------------------------------------------------------*
 | Func:  ViewActv                                                     |
 | Desc:  Popula as tabelas TMP1 (Cabe�alho) e TMP2 (Grid)             |
 | Obs.:  /                                                            |
 *--------------------------------------------------------------------*/
Static Function ViewActv()
    Local oModel    := FWModelActive()
    Local oView     := FWViewActive()
    Local oStrTMP1  := oModel:GetModel("TABTMP1")
    Local oStrTMP2  := oModel:GetModel("TABTMP2")
    Local cQry      := ""
    Local cQrySC9   := ""
    Local __cAlias  := "TMP1"+FWTimeStamp(1)
    Local _cAliasC9 := "TSC9"+FWTimeStamp(1)
    Local nItensTot := 0
    Local nVlrTotal := 0
    Local nPesoTot  := 0
    Local nQtdLib   := 0
    Local nPesoLib  := 0
    Local nLinWhile := 0
    Local cLegend   := ""
    Local lTemSC9   := .F.
    Local lContinua := .T.

    cQry := " SELECT DISTINCT SC5.C5_FILIAL, SC5.C5_NUM, SC5.C5_EMISSAO, SC5.C5_SUGENT, SUM(SC6.C6_QTDVEN) AS QTDVEN, "
    cQry += " SUM(SC6.C6_VALOR) AS VALOR, SC5.C5_CLIENTE, SC5.C5_LOJACLI, SA1.A1_NOME AS NOMECLI, SC5.C5_VEND1, SC5.C5_DESCMUN, SC5.C5_UFORIG  "
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
    cQry += "   AND	SC5.C5_NOTA = '' "
    cQry += " GROUP BY SC5.C5_FILIAL, SC5.C5_NUM, SC5.C5_EMISSAO, SC5.C5_SUGENT, SC5.C5_CLIENTE, SC5.C5_LOJACLI, SA1.A1_NOME, SC5.C5_VEND1, SC5.C5_DESCMUN, SC5.C5_UFORIG "
    cQry += " ORDER BY SC5.C5_NUM "
    cQry := ChangeQuery(cQry)
    IF Select(__cAlias) <> 0
        (__cAlias)->(DbCloseArea())
    EndIf
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),__cAlias,.T.,.T.)

    DBSelectArea("SC9")

    While (__cAlias)->(!EOF())
        
        lTemSC9   := .F.
        lContinua := .T.
        nQtdLib   := 0
        nPesoLib  := 0

        cQrySC9 := " SELECT * FROM "+ RetSqlName("SC9") +" SC9 "
        cQrySC9 += " WHERE D_E_L_E_T_ <> '*' "
        cQrySC9 += "   AND	C9_FILIAL  = '" + (__cAlias)->C5_FILIAL +"' "
        cQrySC9 += "   AND	C9_PEDIDO  = '" + (__cAlias)->C5_NUM +"' "
        cQrySC9 := ChangeQuery(cQrySC9)
        IF Select(_cAliasC9) <> 0
            (_cAliasC9)->(DbCloseArea())
        EndIf
        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySC9),_cAliasC9,.T.,.T.)

        While (_cAliasC9)->(!Eof())
            
            lTemSC9 := .T.

            If (_cAliasC9)->C9_BLCRED $('01/02/04/09') .OR. !Empty((_cAliasC9)->C9_NFISCAL)
                lContinua := .F.
            ElseIF ! (_cAliasC9)->C9_BLEST $('02/03')
                nQtdLib  += (_cAliasC9)->C9_QTDLIB
                nPesoLib += ( (_cAliasC9)->C9_QTDLIB * Posicione("SB1",1,xFilial("SB1") + (_cAliasC9)->C9_PRODUTO, "B1_PESO" ) )
            EndIF

            (_cAliasC9)->(DBSkip())
        EndDo
        IF Select(_cAliasC9) <> 0
            (_cAliasC9)->(DbCloseArea())
        EndIf

        If lTemSC9 .AND. lContinua .And. nQtdLib > 0

            nLinWhile++
            If nLinWhile > 1
                oStrTMP2:AddLine()
                oStrTMP2:GoLine(nLinWhile)
            EndIF 
            
            cLegend := fnLegdPed((__cAlias)->C5_FILIAL,(__cAlias)->C5_NUM)  
            oStrTMP2:LoadValue("T2_LEGEND" , cLegend                        )
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
        EndIF

        (__cAlias)->(DBSkip())
    EndDo

    IF Select(__cAlias) <> 0
        (__cAlias)->(DbCloseArea())
    EndIf

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
 | Func:  fnLegdPed                                                    |
 | Desc:  Retorna a legenda de status do Pedido de Venda do Grid       |
 | Obs.:  /                                                            |
 *--------------------------------------------------------------------*/
Static Function fnLegdPed(pFilial,pPedido)
    Local aArea   := FWGetArea()
    Local cQuery  := ""
    Local _cAlias := "TMP2"+FWTimeStamp(1)
    Local cLegend := ""

    dbSelectArea("SC5")
    If SC5->(MSSeek( pFilial + pPedido ))
        Do Case
            Case (!Empty(SC5->C5_NOTA) .or. SC5->C5_LIBEROK == 'E') .and. Empty(SC5->C5_BLQ)

                cLegend := "BR_VERMELHO"

            Case SC5->C5_BLQ == '1'
                
                cLegend := "BR_AZUL"

            Case SC5->C5_BLQ == '2'
                
                cLegend := "BR_LARANJA"
        EndCase
    EndIF

    cQuery := "Select * from " + RetSqlName("SC9") + " SC9"
    cQuery += "  where SC9.D_E_L_E_T_ <> '*'"
    cQuery += "    and SC9.C9_FILIAL  = '" + pFilial + "'"
    cQuery += "    and SC9.C9_PEDIDO  = '" + pPedido + "'"
    cQuery := ChangeQuery(cQuery)
    dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),_cAlias,.F.,.T.)

    While (_cAlias)->(!Eof())
        Do Case
            Case (_cAlias)->C9_BLEST $('02/03')  // Bloqueio de Estoque
                
                cLegend := "BR_MARROM"

            Case (_cAlias)->C9_BLCRED $('01/02/04/09')  // Bloqueio de Cr�dito
                
                cLegend := "BR_PINK"

            Case !(_cAlias)->C9_BLEST $('02/03') .AND. !(_cAlias)->C9_BLCRED $('01/02/04/09') .AND. ;
                  ( (_cAlias)->C9_BLWMS $('05/06/07') .OR. Empty((_cAlias)->C9_BLWMS) ) // Pedido Liberado / Encerrado
                
                cLegend := "BR_AMARELO"

            Case !(_cAlias)->C9_BLEST $('02/03') .AND. !(_cAlias)->C9_BLCRED $('01/02/04/09') .AND. ; // Pedido Bloqueado WMS
                  (_cAlias)->C9_BLWMS $('01/02/03')
                
                cLegend := "BR_BRANCO"
        EndCase
        (_cAlias)->(DBSkip())
    EndDo 

    IF SC5->C5_XSTATUS == 'S'
        cLegend := "BR_AZUL_CLARO"
    EndIF
    
    (_cAlias)->(dbCloseArea())

    FWRestArea(aArea)

Return cLegend

/*---------------------------------------------------------------------*
 | Func:  tBtnAll                                                      |
 | Desc:  Bot�o para selecionar todos os registros do GRID             |
 | Obs.:  /                                                            |
 *--------------------------------------------------------------------*/
Static Function tBtnAll(oPanel)
    Local cFont := "Arial"
    Local oFontBtn := TFont():New(cFont,,-14,,.T.)
    
    oBtnT1:= TButton():New( 100, 002, "Marcar/Desmarcar" ,oPanel,{||fSelectAll()}, 70,15,,oFontBtn,.F.,.T.,.F.,,.F.,,,.F. )
    oBtnT2:= TButton():New( 100, 075, "Visualizar Pedido",oPanel,{||fVisualiz() }, 75,15,,oFontBtn,.F.,.T.,.F.,,.F.,,,.F. )
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
 | Func:  fVisualiz                                                    |
 | Desc:  Visualiza o Pedido de Venda posicionado no GRID              |
 | Obs.:  /                                                            |
 *--------------------------------------------------------------------*/
Static Function fVisualiz()
    Local oModel := FWModelActive()
    Local oStrTMP2 := oModel:GetModel("TABTMP2")
    
    dbSelectArea("SC5")
    IF SC5->(MSSeek(oStrTMP2:GetValue("T2_FILIAL") + oStrTMP2:GetValue("T2_NUM")))
        A410Visual("SC5",Recno(),2)
    EndIF 

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

    dbSelectArea("SC5")

    ProcRegua(oStrTMP2:Length())

    For nY := 1 To oStrTMP2:Length()
        oStrTMP2:GoLine(nY)
        If !oStrTMP2:IsDeleted()
            If oStrTMP2:GetValue("T2_MARK")
                IF SC5->(MSSeek(oStrTMP2:GetValue("T2_FILIAL") + oStrTMP2:GetValue("T2_NUM")))
                    IncProc("Enviando pedido " + cValToChar(nY) + " de " + cValToChar(oStrTMP2:Length()) + "...")
                    lEnv++
                    U_PFAT0016()
                EndIF
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
 | Desc:  Fun��o para modificar o lModify e fechar a tela sem            |
 |        apresentar a mensagem "H� altera��es n�o salvas no formul�rio" |
 | Obs.:  /                                                              |
 *----------------------------------------------------------------------*/
Static Function fMyCancel()
    Local oModel := FWModelActive()

    If (!Empty(oModel))
        oModel:lModify := .F.
    EndIf
    
Return .T.
