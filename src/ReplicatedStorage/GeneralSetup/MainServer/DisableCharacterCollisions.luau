local PhysicsService = game:GetService("PhysicsService")
PhysicsService:RegisterCollisionGroup("LocalPlayer")
PhysicsService:RegisterCollisionGroup("OtherPlayer")
PhysicsService:CollisionGroupSetCollidable("LocalPlayer", "OtherPlayer", false)


---------- Return module ----------

return {}
