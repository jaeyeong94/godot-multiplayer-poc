# Godot Multiplayer PoC

Godot 4.3 기반 웹 멀티플레이 프로토타입. WebSocket 멀티플레이어로 2D 박스들을 동기화하고,
GitHub Actions로 Web export → GitHub Pages 자동 배포까지 하는 최소 뼈대다.

## 배포

`main` 브랜치에 push하면 [GitHub Actions](.github/workflows/deploy.yml)가:

1. Godot 4.3-stable headless 바이너리 + export templates를 내려받아 `build/web`으로 Web export
2. `coi-serviceworker.js`를 복사하고 `index.html` `<head>`에 인젝션
   (GitHub Pages는 COOP/COEP 헤더를 못 내려주므로 Service Worker로 우회해 SharedArrayBuffer 확보)
3. GitHub Pages에 배포

배포 URL: https://jaeyeong94.github.io/godot-multiplayer-poc/

## 로컬 실행

Godot 4.3으로 프로젝트를 연 뒤 F5. 한 인스턴스는 Host, 다른 인스턴스는 Join.

## 플레이 방법

- **Host**: 서버를 연다. **Join**: 주소/포트를 입력하고 접속 (예: `localhost`, 포트 `8080`).
- 접속한 플레이어마다 박스가 하나 스폰되고, WASD/방향키로 움직인다.
- 내 박스는 파란색(호스트)·초록색(클라이언트), 다른 사람 박스는 주황색.

## 웹 빌드 관련 주의

- 브라우저는 수신 대기 소켓을 열 수 없어서 **웹 빌드에서는 Host가 불가능**하다.
  호스트는 데스크톱(로컬 실행)으로 띄우거나, 별도 서버에서 headless로 돌려야 한다.
  웹 클라이언트는 Join으로 접속하면 된다.
- GitHub Pages는 HTTPS라서, 웹 클라이언트가 접속할 서버도 `wss://`(TLS)여야 한다
  (`ws://`는 mixed content로 차단됨). `wss://`는 WebSocketMultiplayerPeer에 TLS 인증서를 넣어 사용.
- 로컬 테스트는 `godot --headless` 전용 서버나 데스크톱 호스트 + `ws://localhost:8080`으로 충분하다.
