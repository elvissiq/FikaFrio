#include "Totvs.ch"
#INCLUDE "Topconn.ch"

/*/{Protheus.doc} PFUSATUNF
  Carga de integracao de cadastros ao Fusion
  @type Function de Usuario
  @author TOTVS Recife (Elvis Siqueira)
  @since 08/01/2025
  @version 1.0
  /*/

User Function PFUSATUNF()

  Processa({|| xProcessa()}, "Integrando Registros...")

Return 

Static Function xProcessa()
  Local aRetorn     := {}
  Local nAtual      := 0
  Local nFim        := 0
  Local cEndpoint   := Space(25)
  Local aPerg       := {}
  Local cPedDe      := Space(FWTamSX3("C5_NUM")[1])
  Local cPedAte     := Space(FWTamSX3("C5_NUM")[1])
  Local cCargaDe    := Space(FWTamSX3("DAK_COD")[1])
  Local cCargaAte   := Space(FWTamSX3("DAK_COD")[1])
  Local cQry        := ""
  Local cFilQry     := ""
  Local nSeqFus     := 0
  Local cNota       := ""
  Local cSerie      := ""
  Local cCarga      := ""
  Local cSeqCar     := ""
  Local _cAlias     := GetNextAlias()
  Local aSM0Data1   := FWLoadSM0()
  Local lIntFusion  := SuperGetMv("PC_INTFUSI",.F.,.T.)
	Local oFusion     := IIF(lIntFusion, PCLSFUSION():New(), "")
  Local nY

  For nY := 1 TO Len(aSM0Data1)
    aSM0Data1[nY] := Alltrim(aSM0Data1[nY][02]) + " - " + Alltrim(aSM0Data1[nY][07])
  Next 

  aAdd( aPerg ,{2,"Filial "   , cFilQry  , aSM0Data1 , 100    ,""  ,.T.            })
  aAdd( aPerg ,{1,"Pedido De ", cPedDe   , ""        , ".T." , "" , ".T.", 100, .F.})
  aAdd( aPerg ,{1,"Pedido Ate", cPedAte  , ""        , ".T." , "" , ".T.", 100, .F.})
  aAdd( aPerg ,{1,"Carga De " , cCargaDe , ""        , ".T." , "" , ".T.", 100, .F.})
  aAdd( aPerg ,{1,"Carga Ate" , cCargaAte, ""        , ".T." , "" , ".T.", 100, .F.})
  
  If ParamBox(aPerg ,"Informe os dados",@aRetorn)
    cFilQry   := SubStr(aRetorn[1],1,At("-",aRetorn[1])-2)
    cPedDe    := Alltrim(aRetorn[2])
    cPedAte   := Alltrim(aRetorn[3])
    cCargaDe  := Alltrim(aRetorn[4])
    cCargaAte := Alltrim(aRetorn[5])
  EndIF
  
  If !Empty(cFilQry) .And. !Empty(cPedAte)
    
    cQry := " SELECT DISTINCT C9_FILIAL, C9_PEDIDO, C9_NFISCAL, C9_SERIENF "
    cQry += " FROM " + RetSqlName("SC9")
    cQry += " WHERE D_E_L_E_T_ <> '*' "
    cQry += "       AND C9_FILIAL = '" + cFilQry + "' "
    cQry += "       AND C9_PEDIDO BETWEEN '" + cPedDe + "' AND '" + cPedAte + "' "
    cQry += "       AND C9_CARGA BETWEEN '" + cCargaDe + "' AND '" + cCargaAte + "' "
    cQry += "       AND C9_TPCARGA = '1' "
    cQry += "       AND C9_NFISCAL <> '' "
    cQry := ChangeQuery(cQry)
  	IF Select(_cAlias) <> 0
      (_cAlias)->(DbCloseArea())
    EndIf
	  dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),_cAlias,.T.,.T.)
    Count To nFim
    ProcRegua(nFim)
    (_cAlias)->(DBGoTOP())
    DbSelectArea("SC5")
    
    While (_cAlias)->(!Eof())
      nAtual++
      IncProc("Integrando " + cEndpoint + ", registro " +  cValToChar(nAtual) + " de " + cValToChar(nFim) + "...")
      If SC5->(MSSeek( (_cAlias)->C9_FILIAL + (_cAlias)->C9_PEDIDO ))        
        nSeqFus := 0
        cNota   := (_cAlias)->C9_NFISCAL
        cSerie  := (_cAlias)->C9_SERIENF
        cCarga  := ""
        cSeqCar := ""
        // --- Parametro: 1 - Pedido Venda
        //                2 - Sequencial do Pedido
        //                3 - Testar bloqueio do Pedido
        //                4 - Registro deletado
        // ---------------------------------------------
        aRet := oFusion:LerPedidoVenda(SC5->C5_NUM,nSeqFus,.F.,cNota,cSerie,cCarga,cSeqCar)
        
        If aRet[01]
          oFusion:aRegistro := IIf(Len(aRet[04]) > 0,aRet[04],aRet[03])  // Registro do Pedido de Venda
          // -- Parâmetro: 1   - Normal, B - Bloqueado, 4 - Faturado ou 9 - Cancelar
          // --            S   = Pode formar carga
          // --            .T. = N. Carga
          // --            4   - Nº da Nota Fiscal para atualização no Pedido
          // --            5   - Série da Nota Fiscal para atualização no Pedido
          // -------------------------------------------------------
          oFusion:saveEntregaServico("4","N",.T.,cNota,cSerie)
          aRet := oFusion:Enviar("saveEntregaServico") // Enviar para FUSION
          If !aRet[01]
            ApMsgAlert(aRet[02],"ATENÇÃO - Integração Fusion")
          EndIf
        EndIf
      EndIF 
      (_cAlias)->(dbSkip())
    EndDo

    IF Select(_cAlias) <> 0
	    (_cAlias)->(DBCloseArea())
	  EndIf

  EndIF 

Return
