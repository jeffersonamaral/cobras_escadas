# Cobras & Escadas

Implementação, utilizando a Linguagem Dart/Flutter, do jogo indiano "Cobras e Escadas".

<div align="center">
<img src="https://github.com/jeffersonamaral/cobras_escadas/blob/master/doc/screens/cobras_escadas_screen_01.png" width="30%" border="10px"/>
<img src="https://github.com/jeffersonamaral/cobras_escadas/blob/master/doc/screens/cobras_escadas_screen_02.png" width="30%" border="10px"/>
<img src="https://github.com/jeffersonamaral/cobras_escadas/blob/master/doc/screens/cobras_escadas_screen_03.png" width="30%" border="10px"/>
</div>

## Requisitos

- Flutter SDK 2.2+
- [Opicional] Android Studio 4.2+ (plugins para Dart e Flutter devem estar instalados)
- [Opicional] Visual Studio Code 1.57+ (extensões para Dart e Flutter devem estar instaladas)
- Android SDK (para execução em aparelho/emulador Android)
- Google Chrome (para execução Web)

## Execução

Após clonado, o projeto deve ser aberto usando o Android Studio ou Visual Studio Code. Depois de aberto é necessário executar o comando ```flutter pub get``` no diretório raiz do projeto ou, no Android Studio, usar o menu ```Tools -> Flutter -> Flutter Pub Get``` a fim de recarregar os assets e dependências.

Por fim deve-se executar o projeto selecionando o alvo desejado (_Web_ ou _Mobile_).

Alternativamente é possível iniciar a execução usando o comando ```flutter run -t lib/cobras_escadas.dart``` no diretório raiz do projeto, sem a necessidade de usar o Android Studio ou o Visual Studio Code.

## Testes

Por padrão ao se executar o projeto será exibida a interface gráfica que contém os botões "jogar" referentes a cada jogador. Ao se "jogar" os dados são lançados e assumem valores aleatórios.

### _Test Mode_

Foi adicionado um _Test Mode_ ao projeto que consiste em informar previamente os valores que devem ser assumidos para os dados em cada jogada.
Para habilitar o _Test Mode_ é necessário no arquivo ```cobras_escadas.dart``` alterar os valores de inicialização das seguintes variáveis:

- **_testMode**: deve ser alterada para **_true_**;
- **_playsDelayTestMode**: deve-se informar (em milissegundos) o tempo de espera entre as jogadas que serão feitas como teste;
- **_dicesValuesTestMode**: deve-se informar a lista de valores para os dados, onde cada jogada deve ser representada por um par [<valor_dado_1>, <valor_dado_2>].

#### Exemplo de Inicialização dos Valores dos Dados
```Dart
  _dicesValuesTestMode
    ..add([1, 1]) // 1ª jogada: primeiro dado com valor 1, segundo dado com valor 1
    ..add([2, 1]) // 2ª jogada: primeiro dado com valor 2, segundo dado com valor 1
    ..add([5, 5]) // 3ª jogada: primeiro dado com valor 5, segundo dado com valor 5
    ..add([3, 2]); // 4ª jogada: primeiro dado com valor 3, segundo dado com valor 4
```
**OBS**: É de livre escolha a quantidade de jogadas informadas.

**OBS 2**: Ao se executar o projeto com o _Test Mode_ ativado as jogadas informadas em **__dicesValuesTestMode_** serão automaticamente computadas logo após o início da execução.
