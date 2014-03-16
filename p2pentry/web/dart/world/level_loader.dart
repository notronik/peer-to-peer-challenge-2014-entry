part of game;

class LevelLoader {

    Game game;

    LevelLoader(Game this.game);

    bool load(String url, [Function callback]){
        Future fut;
        HttpRequest.getString(url).then((String data){
            JsonDecoder d = new JsonDecoder();
            dynamic json = d.convert(data);

            __parsePlayer(json["player"]);
            __parseSceneObjects(json["lights"], "Light");
            game.world.attach(game.player);
            __parseSceneObjects(json["entities"], "Entity");

            if(callback!=null) callback(true);
            return true;
        }).catchError((e){
            print("Encountered error while loading level: ${e}");
            if(callback!=null) callback(false);
            return false;
        });
        return false;
    }

    void unloadCurrent(){
        for(int i = 0; i < game.world.attachedEntities.length; i++){
            game.world.detach(game.world.attachedEntities.first);
        }
    }

    void __parsePlayer(dynamic json){
        game.player.sceneAttachment["position"].callMethod("set", [json["start"]["position"]["x"].toDouble(), json["start"]["position"]["y"].toDouble(), json["start"]["position"]["z"].toDouble()]);
        game.player.sceneAttachment["__dirtyPosition"] = true;
    }

    void __parseSceneObjects(dynamic json, String classIdentifier){
        for(dynamic d in json){
            String type = d["type"].toString();
            String correctedType = type.replaceFirst(new RegExp("[a-z]{1}"), type.substring(0, 1).toUpperCase()) + classIdentifier;

            List<dynamic> positionalArguments = new List<dynamic>();
            Map<Symbol, dynamic> namedArguments = new Map<Symbol, dynamic>();
            if(d["positional_arguments"] != null){
                for(dynamic x in d["positional_arguments"]){
                    if(x is List){
                        List<dynamic> attachable = new List<dynamic>();
                        for(dynamic y in x){
                            if(y is Map){
                                dynamic vec = __parseVector(y);
                                if(vec != null) attachable.add(vec);
                            }else{
                                attachable.add(y);
                            }
                        }
                        positionalArguments.add(attachable);
                    }else{
                        positionalArguments.add(x);
                    }
                }
            }

            if(d["named_arguments"] != null){
                d["named_arguments"].forEach((key, value){
                    key = key.splitMapJoin(new RegExp("_[A-Za-z]{1}"), onMatch: (m){
                       return key.substring(m.start + 1, m.start + 2).toUpperCase();
                    });

                    if(value is Map){
                        dynamic vec = __parseVector(value);
                        if(vec != null){
                            namedArguments[new Symbol(key)] = vec;
                        }
                    }else{
                        namedArguments[new Symbol(key)] = value;
                    }
                });
            }

            dynamic attachment;

            switch(correctedType){
                case "AmbientLight": {
                    attachment = new AmbientLight.fromArray(positionalArguments, namedArguments);
                }
                    break;
                case "DirectionalLight": {
                    attachment = new DirectionalLight.fromArray(positionalArguments, namedArguments);
                }
                    break;
                case "CrateEntity": {
                    attachment = new CrateEntity.fromArray(positionalArguments, namedArguments);
                }
                    break;
                case "PlaneEntity": {
                    attachment = new PlaneEntity.fromArray(positionalArguments, namedArguments);
                }
                    break;
                case "PipeEntity": {
                    attachment = new PipeEntity.fromArray(positionalArguments, namedArguments);
                }
                    break;
            }

            game.world.attach(attachment);
        }
    }

    dynamic __parseVector(dynamic json){
        if(json["x"] != null && json["y"] != null && json["z"] != null)
            return new Vector3(json["x"].toDouble(), json["y"].toDouble(), json["z"].toDouble());
        else if(json["x"] != null && json["y"] != null)
            return new Vector2(json["x"].toDouble(), json["y"].toDouble());
        else
            return null;
    }
}