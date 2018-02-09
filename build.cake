FilePath solution = "./src/hwapp.sln";
FilePath testProject = "./src/hwapp.tests/hwapp.tests.csproj";

Task("Clean")
    .Does( () => {
        CleanDirectories("./src/**/obj/*");
    }
    );

Task("Restore")
    .Does( () => {
        DotNetCoreRestore(
            solution.FullPath
        );
    }
    );

Task("Build")
    .IsDependentOn("Clean")
    .IsDependentOn("Restore")
    .Does( () => {
        DotNetCoreBuild(
            solution.FullPath,
            new DotNetCoreBuildSettings {
                NoRestore = false
            }
            );
    }
    );

Task("Test")
    .IsDependentOn("Build")
    .Does( () => {
        var settings = new DotNetCoreTestSettings {
                NoBuild = false,
                NoRestore = false,
                
            };


        DotNetCoreTest(
            testProject.FullPath,
            settings
            );
    }
    );


RunTarget("Test");