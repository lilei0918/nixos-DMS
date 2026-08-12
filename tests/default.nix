{
  lib,
  myvars,
  outputs,
}: let
  # 自动发现 ./tests 下的每个测试子目录（expr.nix + expected.nix）
  testDirs = builtins.filter (n: n != "default.nix") (
    builtins.attrNames (builtins.readDir ./.)
  );

  runTest = name: let
    args = {
      inherit lib myvars outputs;
    };
    expr = import (./. + "/${name}/expr.nix") args;
    expected = import (./. + "/${name}/expected.nix") args;
  in
    assert lib.assertMsg (expr == expected) ''
      测试「${name}」失败！
      expr:     ${builtins.toJSON expr}
      expected: ${builtins.toJSON expected}
    ''; true;
in
  builtins.listToAttrs (map (name: {
      name = name;
      value = runTest name;
    })
    testDirs)
