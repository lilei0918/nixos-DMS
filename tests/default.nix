{
  lib,
  myvars,
  outputs,
}: let
  # 自动发现 ./tests 下的每个测试子目录（expr.nix + expected.nix）
  # 只收目录，自动忽略 README.md / default.nix 等文件
  dir = builtins.readDir ./.;

  testDirs = builtins.filter (n: dir.${n} == "directory") (builtins.attrNames dir);

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
      inherit name;

      value = runTest name;
    })
    testDirs)
