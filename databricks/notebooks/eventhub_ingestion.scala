import org.apache.spark.eventhubs.{ ConnectionStringBuilder, EventHubsConf, EventPosition }
import org.apache.spark.sql.functions.{ explode, split }

val eventhub_connection = dbutils.secrets.get("azure-key-vault", "eh-databricks")
val connectionString = ConnectionStringBuilder(eventhub_connection)
  .setEventHubName("telemetry")
  .build
val eventHubsConf = EventHubsConf(connectionString)
  .setStartingPosition(EventPosition.fromEndOfStream)
  
val eventhubs = spark.readStream
  .format("eventhubs")
  .options(eventHubsConf.toMap)
  .load()

val df = eventhubs.select($"body".cast("string"))
 
display(df)