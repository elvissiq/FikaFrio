#Include "TOTVS.CH"

//---------------------------------------------------------
/*/ Rotina MATA460 
  Ponto de entrada M460FIM

   Gravação dos dados após gerar a NF de Saída
   Este P.E. é chamado após a gravação da NF de Saída e
   fora da transação.
    
   Implementado para:
    - Enviar o número da NF para FUSION.

  @parametros PARAMIXB[1] - Número da NF
              PARAMIXB[2] - Série da NF
              PARAMIXB[3] - Cliente/fornecedor da NF
              PARAMIXB[4] - Loja da NF
  @author Anderson Almeida - TOTVS
  @since   17/10/2024 
/*/
//----------------------------------------------------------
User Function M460FIM()
//  Local cNumNFS   := ParamIXB[1]       // Número da NF
//  Local cSerieNFS := ParamIXB[2]       // Série da NF
//  Local cClieFor  := ParamIXB[3]       // Cliente/fornecedor da NF
//  Local cLoja     := ParamIXB[4]       // Loja da NF
  Local cNumNFS   := SF2->F2_DOC       // Número da NF
  Local cSerieNFS := SF2->F2_SERIE     // Série da NF
  Local cClieFor  := SF2->F2_CLIENTE   // Cliente/fornecedor da NF
  Local cLoja     := SF2->F2_LOJA      // Loja da NF

  Local oFusion   := PCLSFUSION():New()
  Local aRet      := {}
  Local cQry      := ""

  If Empty(SF2->F2_CARGA)
     Return
  EndIf

  cQry := "Select SD2.D2_PEDIDO, SC9.C9_XSEQFUS"
  cQry += "  from " + RetSQLName("SD2") + " SD2, " + RetSQLName("SC9") + " SC9"
  cQry += "   where SD2.D_E_L_E_T_ <> '*' "
  cQry += "     and SD2.D2_FILIAL  = '" + FWxFilial("SD2") + "'"
  cQry += "     and SD2.D2_CLIENTE = '" + cClieFor + "'"
  cQry += "     and SD2.D2_LOJA    = '" + cLoja + "'"
  cQry += "     and SD2.D2_DOC     = '" + cNumNFS + "'"
  cQry += "     and SD2.D2_SERIE   = '" + cSerieNFS + "'"
  cQry += "     and SC9.D_E_L_E_T_ <> '*'"
  cQry += "     and SC9.C9_FILIAL  = '" + FWxFilial("SC9") + "'"
  cQry += "     and SC9.C9_NFISCAL = '" + cNumNFS + "'"
  cQry += "     and SC9.C9_SERIENF = '" + cSerieNFS + "'"
  cQry := ChangeQuery(cQry) 
  dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),"TSD2",.F.,.T.)
 
  If ! TSD2->(Eof())
     aRet := oFusion:lerPedidoVenda(TSD2->D2_PEDIDO, Val(TSD2->C9_XSEQFUS), .F., SF2->F2_DOC, SF2->F2_SERIE,"","")

     If aRet[01]
        If Len(aRet[04]) > 0                                   // Itens do Pedido de Venda Liberada
           oFusion:aRegistro := aRet[04] 

           oFusion:saveEntregaServico("4","N",.T.,SF2->F2_DOC,SF2->F2_SERIE)     // 1 - Normal, B - Bloqueado ou C - Cancelado e Forma Carga
          
           aRet := oFusion:Enviar("saveEntregaServico")        // Enviar para FUSION

           If ! aRet[01]
              ApMsgAlert(aRet[02],"ATENÇÃO")  
           EndIf
        EndIf
      else
        ApMsgAlert(aRet[02],"ATENÇÃO")	    
	 EndIf
  EndIf

  TSD2->(dbCloseArea()) 
Return
