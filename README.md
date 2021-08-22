# cobras_escadas

Implementação, utilizando a Linguagem Dart/Flutter, do jogo indiano "Cobras e Escadas".

## Requisitos

- Flutter SDK 2.2+
- Android Studio 4.2+ (Plugins para Dart e Flutter devem estar instalados)
- Android SDK (para execução em aparelho/emulador Android)
- Google Chrome (para execução Web)

## Execução

Após clonado, o projeto deve ser aberto no Android Studio através do menu ```File -> Open```. Depois de aberto é necessário executar o comando ```flutter pub get``` no diretório raiz do projeto ou, no Android Studio, usar o menu ```Tools -> Flutter -> Flutter Pub Get``` a fim de recarregar os assets e dependências.

Por fim deve-se usar o botão ```Run``` selecionando o alvo desejado (_Web_ ou _Mobile_).

## Testes

Por padrão ao se executar o projeto será exibida a interface gráfica que contém os botões "jogar" referentes a cada jogador. Ao se "jogar" os dados são lançados e assumem valores aleatórios.

### _Test Mode_

Foi adicionado um _Test Mode_ ao projeto que consiste em informar previamente os valores que devem ser assumidos para os dados em cada jogada.
Para habilitar o _Test Mode_ é necessário no arquivo ```cobras_escadas.dart``` alterar os valores de inicialização das seguintes variáveis:

- **_testMode**: deve ser alterada para **_true_**;
- **_playsDelayTestMode**: deve-se informar (em milissegundos) o tempo de espera entre as jogadas que serão feitas como teste;
- **_dicesValuesTestMode**: deve-se informar a lista de valores para os dados, onde cada jogada deve ser representada por um par [<valor_dado_1>, <valor_dado_2>].
