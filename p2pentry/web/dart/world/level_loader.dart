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
        game.world.lastStart = new Vector3(json["start"]["position"]["x"].toDouble(), json["start"]["position"]["y"].toDouble(), json["start"]["position"]["z"].toDouble());
        game.world.lastFinish = new Vector3(json["finish"]["position"]["x"].toDouble(), json["finish"]["position"]["y"].toDouble(), json["finish"]["position"]["z"].toDouble());
        game.player.teleport(game.world.lastStart);

        List<JsObject> jpoints = new List<JsObject>();
        for(Map o in json["camera_rail"]){
            Vector3 p = __parseVector(o);
            jpoints.add(new JsObject(context["THREE"]["Vector3"], [p.x, p.y, p.z]));
        }
        game.player.notify(EntityNotifications.NF_PLAYER_CAMERA_RAIL, new JsObject(context["THREE"]["SplineCurve3"], [new JsArray.from(jpoints)]));
    }

    void __parseSceneObjects(dynamic json, String classIdentifier){
        for(dynamic d in json){
            String type = d["type"].toString();
            type = type.splitMapJoin(new RegExp("_[A-Za-z]{1}"), onMatch: (m){
               return type.substring(m.start + 1, m.start + 2).toUpperCase();
            });
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
                    attachment = EntityFactory.createAmbientLight(positionalArguments, namedArguments);
                }
                    break;
                case "DirectionalLight": {
                    attachment = EntityFactory.createDirectionalLight(positionalArguments, namedArguments);
                }
                    break;
                case "CrateEntity": {
                    attachment = EntityFactory.createCrate(positionalArguments, namedArguments);
                }
                    break;
                case "PlaneEntity": {
                    attachment = EntityFactory.createPlane(positionalArguments, namedArguments);
                }
                    break;
                case "PipeEntity": {
                    attachment = EntityFactory.createPipe(positionalArguments, namedArguments);
                }
                    break;
                case "PerforatedPipeEntity": {
                    attachment = EntityFactory.createPerforatedPipe(positionalArguments, namedArguments);
                }
                    break;
                case "PipeInsertAccelEntity": {
                    attachment = EntityFactory.createPipeInsertACCEL(positionalArguments, namedArguments);
                }
            }
            attachment.isReady(() => game.world.attach(attachment));
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