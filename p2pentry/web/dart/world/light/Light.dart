part of game;

abstract class Light extends SceneObject {

    num __color = 0xffffff;

    Light(Vector3 position, Vector3 rotation, num this.__color) : super(position, rotation);

    void set color(num newColor){
        this.__color = newColor;
        this.sceneAttachment["color"] = newColor;
    }

    num get color {
        return this.__color;
    }

}