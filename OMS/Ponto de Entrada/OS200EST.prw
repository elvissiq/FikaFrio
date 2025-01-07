#Include "Protheus.ch"
#Include "TOPCONN.ch"
#Include "TOTVS.ch"

//--------------------------------------------------------
/*/ Rotina OMSA200
  Ponto de entrada OS200EST

   Tratativa ao estornar a carga.
    
   Implementado para:
     - Enviar cancelamento de Carga para o FUSION.

  @author Anderson Almeida - TOTVS
  @since   06/01/2024 
/*/
//--------------------------------------------------------
User Function OS200EST()
  Local oFusion := PCLSFUSION():New()
  Local cCarga  := ParamIxb[1]
  Local cSeqCar := ParamIxb[2]
  Local cQry    := ""
  Local cMsg    := ""

  cQry := "Select Distinct SC9.C9_PEDIDO, SC9.C9_XSEQFUS"
  cQry += "  from " + RetSQLName("SC9") + " SC9, " + RetSQLName("SC5") + " SC5"
  cQry += "   where SC9.D_E_L_E_T_ <> '*'"
  cQry += "     and SC9.C9_FILIAL  = '" + FWxFilial("SC9") + "'"
  cQry += "     and SC9.C9_CARGA   = '" + cCarga  + "'"
  cQry += "     and SC9.C9_SEQCAR  = '" + cSeqCar  + "'"
  cQry += "     and SC9.C9_XSEQFUS <> ''"
  cQry += "     and SC5.D_E_L_E_T_ <> '*'"
  cQry += "     and SC5.C5_FILIAL  = '" + FWxFilial("SC5") + "'"
  cQry += "     and SC5.C5_NUM     = SC9.C9_PEDIDO"
  cQry += "     and SC5.C5_TPCARGA = '1'"
  cQry := ChangeQuery(cQry)
  dbUseArea(.T.,"TOPCONN",TCGenQRY(,,cQry),"TSC9",.F.,.T.)

  While ! TSC9->(Eof())
    aRet := oFusion:lerPedidoVenda(TSC9->C9_PEDIDO,Val(TSC9->C9_XSEQFUS),.F.,"","",cCarga,cSeqCar)

    If ! aRet[01]
       cMsg += "Erro FUSION - pedido " + TSC9->C9_PEDIDO + " da carga " + cCarga + " com problema: " + aRet[02] + Chr(13) + Chr(10)
     else
       oFusion:aRegistro := aRet[04]                      // Registro do Pedido de Venda
          
      //@Parâmetro:  01 - '1' = Aprovado
      //                  'B' = Bloqueio Financeiro
      //                  'C' = Bloqueio Comercial
      //                  '9' = Cancelado
      //             02 - 'S' = Sim forma carga
      //                  'N' = Não forma carga 
      //             03 - .T. = Número da carga
      //                  .F. = Sem número da carga 
      //             04 - Número da Nota Fiscal
      //             05 - Série da Nota Fiscal
      // --------------------------------------------------------------------
       oFusion:saveEntregaServico("1","S",.F.,"","")

       aRet := oFusion:Enviar("saveEntregaServico") // Enviar para FUSION

       If ! aRet[01]
          cMsg += "Erro FUSION - pedido " + TSC9->C9_PEDIDO + " da carga " + cCarga + " com problema: " + aRet[02] + Chr(13) + Chr(10)
        else
          cMsg += "Pedido " + TSC9->C9_PEDIDO + " da carga " + cCarga + " estornado com sucesso no FUSION." + Chr(13) + Chr(10)
       EndIf
    EndIf

    TSC9->(dbSkip())
  EndDo

  TSC9->(dbCloseArea())

  If ! Empty(cMsg)
     ApMsgInfo(cMsg,"ATENÇÃO")
  EndIf
Return
