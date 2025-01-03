
#Include "TOTVS.ch"
#Include "TOPCONN.ch"
#Include "PROTHEUS.CH"

// ------------------------------------------------------
/*/ Rotina FFOMSM01

   Levar veículos 

  @author Anderson Almeida - TOTVS
  @since   28/08/2024 
/*/
//--------------------------------------------------------
User Function LEVAVEI()
Local oFusion := PCLSFUSION():New()
  Local aRet    := {}
 
dbSelectArea("DA4")
DA4->(dbSetOrder(1))

While ! DA4->(Eof())
  oFusion:sendMotoristas(DA4->DA4_COD)              // Montar requisição de envio

  aRet := oFusion:Enviar("sendMotoristas")

  DA4->(dbSkip())
EndDo
/*
dbSelectArea("DAU")
DAU->(dbSetOrder(1))

While ! DAU->(Eof())
  oFusion:sendAjudantes(DAU->DAU_COD)              // Montar requisição de envio

  aRet := oFusion:Enviar("sendMotoristas")

  DAU->(dbSkip())
EndDo

dbSelectArea("DA3")
DA3->(dbSetOrder(1))

While ! DA3->(Eof())
  oFusion:sendVeiculos(DA3->DA3_COD)                 // Montar requisição de envio

  aRet := oFusion:Enviar("sendVeiculos")             // Enviar para FUSION

  DA3->(dbSkip())
EndDo 
*/
     ApMsgInfo("Dados do Motorista/Ajudante/Veículo enviado para FUSION com sucesso.")
/*
dbSelectArea("SA1")
SA1->(dbSetOrder(1))

While ! SA1->(Eof())
  oFusion:sendClientes(SA1->A1_COD, SA1->A1_LOJA)    // Montar requisição de envio

  aRet := oFusion:Enviar("sendClientes")             // Enviar para FUSION

  SA1->(dbSkip())
EndDo


ApMsgInfo("Dados do Clientes enviado para FUSION com sucesso.")
*/
Return
