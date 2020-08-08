part of arrow_framework;

List<ClassMirror> scanControllers() {
  var mirrorSystem = currentMirrorSystem();
  var controllers = <ClassMirror>[];
  var declarations = mirrorSystem.isolate.rootLibrary.declarations;
  var ArrowControllerMirror = reflectClass(ArrowController);

  for (var mirror in declarations.values) {
    if (mirror is ClassMirror) {
      // is class
      if (mirror.isSubclassOf(ArrowControllerMirror)) {
        // is arrow controller
        controllers.add(mirror);
      }
    }
  }

  return controllers;
}