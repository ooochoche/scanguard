export function getEnvPath() {
  //? we might implement some complex env file getting logic here
  //? for now we just return the sample env file

  return `${process.cwd()}/.env.sample`;
}
