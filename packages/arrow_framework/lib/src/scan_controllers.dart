part of arrow_framework;

List<ClassMirror> scanControllers() {
  final mirrorSystem = currentMirrorSystem();
  final controllers = <ClassMirror>[];
  final declarations = mirrorSystem.isolate.rootLibrary.declarations;
  final ArrowControllerMirror = reflectClass(ArrowController);

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
