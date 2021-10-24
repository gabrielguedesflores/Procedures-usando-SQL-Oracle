CREATE OR REPLACE PROCEDURE prc_importacao_bens (p_data DATE
                                                ,p_lote NUMBER) AS

------- CURSOR CONTABIL TP=N -------------

CURSOR C_DADOS_CONTABIL_TPN IS

SELECT data_tombamento dt_lancamento
, cod_reduzido_ativo   cd_reduzido
, cod_bem              cd_bem
, valor_compra         vl_compra
, desc_bem             ds_tombamento
, valor_compra         vl_compra2
FROM bens_sw
WHERE tipo_origem = 'M'
AND sn_despesa_operacional = 'N'
AND Trunc(data_tombamento, 'month') = Trunc(p_data, 'MONTH')
ORDER BY cod_bem ASC
 ;

------- CURSOR CONTABIL TP=S -------------

CURSOR C_DADOS_CONTABIL_TPS IS

SELECT data_tombamento dt_lancamento
, cod_reduzido_ativo   cd_reduzido
, cod_bem              cd_bem
, valor_compra         vl_compra
, desc_bem             ds_tombamento
, valor_compra         vl_compra2

FROM bens_sw
WHERE tipo_origem = 'M'
AND sn_despesa_operacional = 'S'
AND Trunc(data_tombamento, 'month') = Trunc(p_data, 'MONTH')
ORDER BY cod_bem ASC
 ;

------- CURSOR SETOR  -------------

CURSOR C_DADOS_SETOR IS

SELECT valor_lancado
, cod_lcto_contabil
, cod_lcto_movimento
, COD_SETOR
FROM tab_contabil, BENS_SW
WHERE cod_reduzido_deb = 2323
AND Trunc(data_lcto, 'month') = Trunc(p_data, 'MONTH')
AND cod_lote = p_lote
AND BENS_SW.COD_BEM = REPLACE (DESC_COMPLEMENTO, 'Tombamento do Bem Patrimonial de código: ', '')

ORDER BY desc_complemento asc
 ;



V_DADOS_CONTABIL_TPN C_DADOS_CONTABIL_TPN%rowtype;

V_DADOS_CONTABIL_TPS C_DADOS_CONTABIL_TPS%rowtype;

V_DADOS_SETOR C_DADOS_SETOR%rowtype;


v_lote NUMBER :=  p_lote;


BEGIN

------------ FETCH DO CURSOS C_DADOS_CONTABIL_TPN ------------------------


    OPEN  C_DADOS_CONTABIL_TPN;
     loop
        fetch C_DADOS_CONTABIL_TPN into V_DADOS_CONTABIL_TPN;
        exit when C_DADOS_CONTABIL_TPN%notfound;
        INSERT INTO tab_contabil (cd_tab_contabil
                             , data_lcto
                             , cod_reduzido_deb
                             , cod_reduzido_cred
                             , valor_lancado
                             , cod_historico_padrao
                             , desc_complemento
                             , cod_lote
                             , cod_lcto_movimento
                             , valor_moeda_lancado
                             , cod_moeda
                             , cod_multi_empresa
                             , cod_multi_empresa_origem)
                 VALUES ( sequence_tab_contabil.nextval
                             , V_DADOS_CONTABIL_TPN.data_lancamento
                             , V_DADOS_CONTABIL_TPN.cod_reduzido
                             , '2219'
                             ,  V_DADOS_CONTABIL_TPN.valor_compra
                             , '96'
                             , 'Tombamento do Bem Patrimonial de código: '||V_DADOS_CONTABIL_TPN.cod_bem
                             , v_lote
                             , sequence_lancamento_movimento.nextval
                             , V_DADOS_CONTABIL_TPN.valor_compra2
                             , 'R$'
                             , '2'
                             , '2');

         COMMIT  ;

    end loop;
    CLOSE C_DADOS_CONTABIL_TPN;

------------ FIM DO C_DADOS_CONTABIL_TPN ---------------------------------


------------ FETCH DO CURSOR C_DADOS_CONTABIL_TPS ------------------------



    OPEN  C_DADOS_CONTABIL_TPS;  ------ INICIO DO TPS
     loop
        fetch C_DADOS_CONTABIL_TPS into V_DADOS_CONTABIL_TPS;
        exit when C_DADOS_CONTABIL_TPS%notfound;
        INSERT INTO tab_contabil (cod_tab_contabil
                             , data_lcto
                             , cod_reduzido_deb
                             , cod_reduzido_cred
                             , valor_lancado
                             , cod_historico_padrao
                             , desc_complemento
                             , cod_lote
                             , cod_lcto_movimento
                             , valor_moeda_lancado
                             , cod_moeda
                             , cod_multi_empresa
                             , cod_multi_empresa_origem)
                 VALUES ( sequence_tab_contabil.nextval
                             , V_DADOS_CONTABIL_TPS.data_lancamento
                             , '2323'
                             , '2219'
                             ,  V_DADOS_CONTABIL_TPS.valor_compra
                             , '96'
                             , 'Tombamento do Bem Patrimonial de código: '||V_DADOS_CONTABIL_TPS.cod_bem
                             , v_lote
                             , sequence_lancamento_movimento.nextval
                             , V_DADOS_CONTABIL_TPS.valor_compra2
                             , 'R$'
                             , '2'
                             , '2');

         COMMIT  ;

    end loop;
    CLOSE C_DADOS_CONTABIL_TPS;

------------ FIM DO C_DADOS_CONTABIL_TPS ---------------------------------


------------ FETCH DO CURSOR C_DADOS_SETOR -------------------------------

    OPEN  C_DADOS_SETOR;
     loop
        fetch C_DADOS_SETOR into V_DADOS_SETOR;
        exit when C_DADOS_SETOR%notfound;
        INSERT INTO lancamento_setor (cod_lancamento_setor
                                      , valor_lancamento_setor
                                      , cod_tab_contabil
                                      , cod_setor_deb
                                      , cod_lancamento_movimento
                                      , valor_moeda_lancamento_setor
                                      , cod_moeda)

                                       values (sequence_lancamento_setor.NEXTVAL
                                      , V_DADOS_SETOR.valor_lancado
                                      , V_DADOS_SETOR.cod_tab_contabil
                                      , V_DADOS_SETOR.cod_setor
                                      , V_DADOS_SETOR.cod_lancamento_movimento
                                      , V_DADOS_SETOR.valor_lancado
                                      , 'R$');
         COMMIT  ;

    end loop;
    CLOSE C_DADOS_SETOR;

------------ FIM DO C_DADOS_SETOR -------------------------------


    END;
/

