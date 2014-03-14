part of game;

abstract class ShadowMixin {

    void enableShadows(JsObject sceneAttachment, {bool cast:true, bool receive:true}){
        sceneAttachment["castShadow"] = cast;
        sceneAttachment["receiveShadow"] = receive;
    }

}